const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// Listar vendas (com filtros)
router.get("/", async (req, res) => {
  try {
    const { status, caixaId, usuarioId, limit } = req.query;
    let sql = `
      SELECT v.*, u.nome AS usuario_nome, p.nome AS pessoa_nome
      FROM vendas v
      LEFT JOIN usuarios u ON u.id = v.usuario_id
      LEFT JOIN pessoas p ON p.id = v.pessoa_id
      WHERE 1=1
    `;
    const params = [];

    if (status) { sql += " AND v.status = ?"; params.push(status); }
    if (caixaId) { sql += " AND v.caixa_id = ?"; params.push(caixaId); }
    if (usuarioId) { sql += " AND v.usuario_id = ?"; params.push(usuarioId); }

    sql += " ORDER BY v.id DESC LIMIT ?";
    params.push(Number(limit) || 200);

    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar vendas." });
  }
});

// Buscar venda por ID (com itens e pagamentos)
router.get("/:id", async (req, res) => {
  try {
    const vendaId = req.params.id;

    const [vendas] = await pool.query(
      `SELECT v.*, u.nome AS usuario_nome, p.nome AS pessoa_nome
       FROM vendas v
       LEFT JOIN usuarios u ON u.id = v.usuario_id
       LEFT JOIN pessoas p ON p.id = v.pessoa_id
       WHERE v.id = ?`,
      [vendaId]
    );
    if (vendas.length === 0) return res.status(404).json({ message: "Venda não encontrada." });

    const [itens] = await pool.query(
      `SELECT vi.*, pr.descricao AS produto_descricao
       FROM venda_itens vi
       LEFT JOIN produtos pr ON pr.id = vi.produto_id
       WHERE vi.venda_id = ?`,
      [vendaId]
    );

    const [pagamentos] = await pool.query(
      `SELECT vp.*, fp.descricao AS forma_descricao
       FROM venda_pagamentos vp
       LEFT JOIN formas_pagamento fp ON fp.id = vp.forma_pagamento_id
       WHERE vp.venda_id = ?`,
      [vendaId]
    );

    res.json({ ...vendas[0], itens, pagamentos });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar venda." });
  }
});

// Criar venda (multi-pagamento, descontos, estoque)
router.post("/", async (req, res) => {
  const { caixaId, usuarioId, pessoaId, itens, pagamentos, observacoes, descontoVenda } = req.body || {};

  if (!caixaId || !usuarioId) return res.status(400).json({ message: "caixaId e usuarioId são obrigatórios." });
  if (!Array.isArray(itens) || !itens.length) return res.status(400).json({ message: "itens obrigatórios." });

  // Calcular total com descontos por item
  let totalBruto = 0;
  let totalDescontoItens = 0;
  for (const item of itens) {
    const itemTotal = Number(item.preco) * Number(item.quantidade);
    totalBruto += itemTotal;
    totalDescontoItens += Number(item.descontoValor || 0);
  }

  const desconto = totalDescontoItens + Number(descontoVenda || 0);
  const acrescimo = 0;
  const totalLiquido = totalBruto - desconto + acrescimo;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [resVenda] = await conn.query(
      `INSERT INTO vendas
        (caixa_id, usuario_id, pessoa_id, data_hora, total_bruto, desconto, acrescimo, total_liquido, status, numero_nfe, observacoes)
       VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)`,
      [caixaId, usuarioId, pessoaId || null, totalBruto, desconto, acrescimo, totalLiquido, "FINALIZADA", 0, observacoes || null]
    );

    const vendaId = resVenda.insertId;

    for (const item of itens) {
      const valorTotal = Number(item.preco) * Number(item.quantidade);
      await conn.query(
        `INSERT INTO venda_itens (venda_id, produto_id, quantidade, valor_unitario, valor_total, desconto_percentual, desconto_valor)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [vendaId, item.produtoId, item.quantidade, item.preco, valorTotal, item.descontoPercentual || 0, item.descontoValor || 0]
      );

      // Descontar estoque
      const [prods] = await conn.query("SELECT estoque_atual FROM produtos WHERE id = ?", [item.produtoId]);
      if (prods.length > 0) {
        const anterior = Number(prods[0].estoque_atual);
        const posterior = anterior - Number(item.quantidade);
        await conn.query("UPDATE produtos SET estoque_atual = ? WHERE id = ?", [posterior, item.produtoId]);
        await conn.query(
          `INSERT INTO movimentos_estoque (produto_id, tipo, quantidade, estoque_anterior, estoque_posterior, usuario_id, referencia_id, referencia_tipo)
           VALUES (?, 'VENDA', ?, ?, ?, ?, ?, 'VENDA')`,
          [item.produtoId, item.quantidade, anterior, posterior, usuarioId, vendaId]
        );
      }
    }

    // Multi-pagamento
    const pags = Array.isArray(pagamentos) && pagamentos.length > 0
      ? pagamentos
      : [{ formaPagamentoId: 1, valor: totalLiquido }];

    for (const pag of pags) {
      await conn.query(
        `INSERT INTO venda_pagamentos (venda_id, forma_pagamento_id, valor)
         VALUES (?, ?, ?)`,
        [vendaId, pag.formaPagamentoId, pag.valor]
      );
    }

    await conn.commit();
    res.json({ vendaId });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    res.status(500).json({ message: "Erro ao salvar venda.", detail: String(e) });
  } finally {
    conn.release();
  }
});

// Cancelar venda (reverte estoque)
router.patch("/:id/cancelar", async (req, res) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [vendas] = await conn.query("SELECT * FROM vendas WHERE id = ? AND status = 'FINALIZADA'", [req.params.id]);
    if (vendas.length === 0) {
      await conn.rollback();
      return res.status(404).json({ message: "Venda não encontrada ou já cancelada." });
    }

    await conn.query("UPDATE vendas SET status = 'CANCELADA' WHERE id = ?", [req.params.id]);

    // Reverter estoque
    const [itensVenda] = await conn.query("SELECT * FROM venda_itens WHERE venda_id = ?", [req.params.id]);
    for (const item of itensVenda) {
      const [prods] = await conn.query("SELECT estoque_atual FROM produtos WHERE id = ?", [item.produto_id]);
      if (prods.length > 0) {
        const anterior = Number(prods[0].estoque_atual);
        const posterior = anterior + Number(item.quantidade);
        await conn.query("UPDATE produtos SET estoque_atual = ? WHERE id = ?", [posterior, item.produto_id]);
        await conn.query(
          `INSERT INTO movimentos_estoque (produto_id, tipo, quantidade, estoque_anterior, estoque_posterior, usuario_id, referencia_id, referencia_tipo)
           VALUES (?, 'CANCELAMENTO', ?, ?, ?, ?, ?, 'VENDA')`,
          [item.produto_id, item.quantidade, anterior, posterior, req.user.id, req.params.id]
        );
      }
    }

    await conn.commit();
    res.json({ ok: true });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    res.status(500).json({ message: "Erro ao cancelar venda." });
  } finally {
    conn.release();
  }
});

module.exports = router;
