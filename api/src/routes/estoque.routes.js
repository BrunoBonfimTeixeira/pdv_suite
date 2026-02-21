const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /estoque — níveis de estoque (com filtros)
router.get("/", async (req, res) => {
  try {
    const { alerta, categoriaId, q } = req.query;
    let sql = `
      SELECT p.id, p.descricao, p.estoque_atual, p.estoque_minimo, p.unidade_medida,
             p.preco_venda, p.ativo,
             c.descricao AS categoria_descricao, c.id AS categoria_id
      FROM produtos p
      LEFT JOIN categorias c ON c.id = p.categoria_id
      WHERE p.ativo = 1
    `;
    const params = [];

    if (alerta == "1") {
      sql += " AND p.estoque_atual <= p.estoque_minimo";
    }
    if (categoriaId) {
      sql += " AND p.categoria_id = ?";
      params.push(categoriaId);
    }
    if (q) {
      sql += " AND (p.descricao LIKE ? OR p.codigo_barras LIKE ?)";
      const like = `%${q}%`;
      params.push(like, like);
    }

    sql += " ORDER BY p.descricao";
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar estoque." });
  }
});

// GET /estoque/:produtoId/movimentos — histórico de movimentos
router.get("/:produtoId/movimentos", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT m.*, u.nome AS usuario_nome
       FROM movimentos_estoque m
       LEFT JOIN usuarios u ON u.id = m.usuario_id
       WHERE m.produto_id = ?
       ORDER BY m.id DESC
       LIMIT 200`,
      [req.params.produtoId]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar movimentos." });
  }
});

// POST /estoque/ajuste — ajustar estoque manualmente (ADMIN)
router.post("/ajuste", adminRequired, async (req, res) => {
  const { produtoId, tipo, quantidade, motivo } = req.body || {};

  if (!produtoId || !tipo || quantidade === undefined) {
    return res.status(400).json({ message: "produtoId, tipo e quantidade são obrigatórios." });
  }

  if (!["ENTRADA", "SAIDA", "AJUSTE"].includes(tipo)) {
    return res.status(400).json({ message: "tipo deve ser ENTRADA, SAIDA ou AJUSTE." });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [prods] = await conn.query("SELECT estoque_atual FROM produtos WHERE id = ?", [produtoId]);
    if (prods.length === 0) {
      await conn.rollback();
      return res.status(404).json({ message: "Produto não encontrado." });
    }

    const estoqueAnterior = Number(prods[0].estoque_atual);
    let estoqueNovo;

    if (tipo === "ENTRADA") {
      estoqueNovo = estoqueAnterior + Number(quantidade);
    } else if (tipo === "SAIDA") {
      estoqueNovo = estoqueAnterior - Number(quantidade);
    } else {
      // AJUSTE = define valor absoluto
      estoqueNovo = Number(quantidade);
    }

    await conn.query("UPDATE produtos SET estoque_atual = ? WHERE id = ?", [estoqueNovo, produtoId]);

    await conn.query(
      `INSERT INTO movimentos_estoque
        (produto_id, tipo, quantidade, estoque_anterior, estoque_posterior, motivo, usuario_id, referencia_tipo)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'AJUSTE_MANUAL')`,
      [produtoId, tipo, quantidade, estoqueAnterior, estoqueNovo, motivo || null, req.user.id]
    );

    await conn.commit();
    res.json({ ok: true, estoqueAnterior, estoqueNovo });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    res.status(500).json({ message: "Erro ao ajustar estoque." });
  } finally {
    conn.release();
  }
});

module.exports = router;
