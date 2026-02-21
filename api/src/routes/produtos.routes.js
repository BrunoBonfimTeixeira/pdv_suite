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
        "SELECT id, descricao, preco_venda FROM produtos WHERE ativo = 1 ORDER BY descricao"
      );
      return res.json(rows);
    }

    const like = `%${q}%`;
    const [rows] = await pool.query(
      `SELECT id, descricao, preco_venda FROM produtos
       WHERE ativo = 1 AND (descricao LIKE ? OR codigo_barras LIKE ? OR id = ?)
       ORDER BY descricao`,
      [like, like, Number(q) || 0]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao listar produtos" });
  }
});

module.exports = router;
