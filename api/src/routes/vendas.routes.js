const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

router.post("/", async (req, res) => {
  const { caixaId, usuarioId, itens, pagamento } = req.body || {};

  if (!caixaId || !usuarioId) return res.status(400).json({ message: "caixaId e usuarioId são obrigatórios." });
  if (!Array.isArray(itens) || !itens.length) return res.status(400).json({ message: "itens obrigatórios." });

  const agora = new Date();

  const totalBruto = itens.reduce((s, i) => s + (Number(i.preco) * Number(i.quantidade)), 0);
  const desconto = 0;
  const acrescimo = 0;
  const totalLiquido = totalBruto - desconto + acrescimo;

  const formaPagamentoId = pagamento?.formaPagamentoId || 1;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [resVenda] = await conn.query(
      `INSERT INTO vendas
        (caixa_id, usuario_id, data_hora, total_bruto, desconto, acrescimo, total_liquido, status, numero_nfe)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [caixaId, usuarioId, agora, totalBruto, desconto, acrescimo, totalLiquido, "FINALIZADA", 0]
    );

    const vendaId = resVenda.insertId;

    for (const item of itens) {
      await conn.query(
        `INSERT INTO venda_itens (venda_id, produto_id, quantidade, valor_unitario, valor_total)
         VALUES (?, ?, ?, ?, ?)`,
        [vendaId, item.produtoId, item.quantidade, item.preco, Number(item.preco) * Number(item.quantidade)]
      );
    }

    await conn.query(
      `INSERT INTO venda_pagamentos (venda_id, forma_pagamento_id, valor)
       VALUES (?, ?, ?)`,
      [vendaId, formaPagamentoId, totalLiquido]
    );

    await conn.commit();
    res.json({ vendaId });
  } catch (e) {
    await conn.rollback();
    res.status(500).json({ message: "Erro ao salvar venda.", detail: String(e) });
  } finally {
    conn.release();
  }
});

module.exports = router;
