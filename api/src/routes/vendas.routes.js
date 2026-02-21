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

// Criar venda (multi-pagamento)
router.post("/", async (req, res) => {
  const { caixaId, usuarioId, pessoaId, itens, pagamentos } = req.body || {};

  if (!caixaId || !usuarioId) return res.status(400).json({ message: "caixaId e usuarioId são obrigatórios." });
  if (!Array.isArray(itens) || !itens.length) return res.status(400).json({ message: "itens obrigatórios." });

  const totalBruto = itens.reduce((s, i) => s + (Number(i.preco) * Number(i.quantidade)), 0);
  const desconto = 0;
  const acrescimo = 0;
  const totalLiquido = totalBruto - desconto + acrescimo;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [resVenda] = await conn.query(
      `INSERT INTO vendas
        (caixa_id, usuario_id, pessoa_id, data_hora, total_bruto, desconto, acrescimo, total_liquido, status, numero_nfe)
       VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?)`,
      [caixaId, usuarioId, pessoaId || null, totalBruto, desconto, acrescimo, totalLiquido, "FINALIZADA", 0]
    );

    const vendaId = resVenda.insertId;

    for (const item of itens) {
      await conn.query(
        `INSERT INTO venda_itens (venda_id, produto_id, quantidade, valor_unitario, valor_total)
         VALUES (?, ?, ?, ?, ?)`,
        [vendaId, item.produtoId, item.quantidade, item.preco, Number(item.preco) * Number(item.quantidade)]
      );
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

// Cancelar venda
router.patch("/:id/cancelar", async (req, res) => {
  try {
    const [result] = await pool.query(
      "UPDATE vendas SET status = 'CANCELADA' WHERE id = ? AND status = 'FINALIZADA'",
      [req.params.id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Venda não encontrada ou já cancelada." });
    }
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao cancelar venda." });
  }
});

module.exports = router;
