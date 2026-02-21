const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /tabela-nutricional/produto/:produtoId — buscar por produto
router.get("/produto/:produtoId", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM tabela_nutricional WHERE produto_id = ?",
      [req.params.produtoId]
    );
    if (rows.length === 0) return res.status(404).json({ message: "Tabela nutricional não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar tabela nutricional." });
  }
});

// POST /tabela-nutricional — criar/upsert (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const {
      produto_id, porcao, unidade_porcao,
      energia_kcal, carboidratos, proteinas,
      gorduras_totais, gorduras_saturadas, gorduras_trans,
      fibras, sodio
    } = req.body || {};

    if (!produto_id) return res.status(400).json({ message: "produto_id é obrigatório." });

    const [result] = await pool.query(
      `INSERT INTO tabela_nutricional
        (produto_id, porcao, unidade_porcao, energia_kcal, carboidratos, proteinas,
         gorduras_totais, gorduras_saturadas, gorduras_trans, fibras, sodio)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
        porcao=VALUES(porcao), unidade_porcao=VALUES(unidade_porcao),
        energia_kcal=VALUES(energia_kcal), carboidratos=VALUES(carboidratos),
        proteinas=VALUES(proteinas), gorduras_totais=VALUES(gorduras_totais),
        gorduras_saturadas=VALUES(gorduras_saturadas), gorduras_trans=VALUES(gorduras_trans),
        fibras=VALUES(fibras), sodio=VALUES(sodio)`,
      [
        produto_id, porcao || null, unidade_porcao || null,
        energia_kcal || 0, carboidratos || 0, proteinas || 0,
        gorduras_totais || 0, gorduras_saturadas || 0, gorduras_trans || 0,
        fibras || 0, sodio || 0
      ]
    );
    res.status(201).json({ id: result.insertId || produto_id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao salvar tabela nutricional." });
  }
});

module.exports = router;
