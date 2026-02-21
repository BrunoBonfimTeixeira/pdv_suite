const express = require("express");
const router = express.Router();
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

// Apenas autenticação (sem exigir ADMIN) — rota pública para operadores do PDV
router.use(authRequired);

// GET /produtos?q= ou ?filtro=
router.get("/", async (req, res) => {
  try {
    const q = (req.query.q || req.query.filtro || "").toString().trim();
    if (!q) {
      const [rows] = await pool.query(
        `SELECT p.id, p.descricao, p.preco_venda, p.unidade_medida, p.estoque_atual, p.codigo_barras,
                p.categoria_id, c.descricao AS categoria_descricao
         FROM produtos p LEFT JOIN categorias c ON c.id = p.categoria_id
         WHERE p.ativo = 1 ORDER BY p.descricao`
      );
      return res.json(rows);
    }

    const like = `%${q}%`;
    const [rows] = await pool.query(
      `SELECT p.id, p.descricao, p.preco_venda, p.unidade_medida, p.estoque_atual, p.codigo_barras,
              p.categoria_id, c.descricao AS categoria_descricao
       FROM produtos p LEFT JOIN categorias c ON c.id = p.categoria_id
       WHERE p.ativo = 1 AND (p.descricao LIKE ? OR p.codigo_barras LIKE ? OR p.id = ?)
       ORDER BY p.descricao`,
      [like, like, Number(q) || 0]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao listar produtos" });
  }
});

module.exports = router;
