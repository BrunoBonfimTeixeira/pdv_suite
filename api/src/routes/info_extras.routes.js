const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /info-extras/produto/:produtoId — listar por produto
router.get("/produto/:produtoId", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM info_extras WHERE produto_id = ? ORDER BY chave",
      [req.params.produtoId]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar informações extras." });
  }
});

// POST /info-extras — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const { produto_id, chave, valor } = req.body || {};
    if (!produto_id || !chave) {
      return res.status(400).json({ message: "produto_id e chave são obrigatórios." });
    }

    const [result] = await pool.query(
      "INSERT INTO info_extras (produto_id, chave, valor) VALUES (?, ?, ?)",
      [produto_id, chave, valor || null]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar informação extra." });
  }
});

// PATCH /info-extras/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { chave, valor } = req.body || {};
    const updates = [];
    const params = [];

    if (chave !== undefined) { updates.push("chave=?"); params.push(chave); }
    if (valor !== undefined) { updates.push("valor=?"); params.push(valor); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE info_extras SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Informação extra não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar informação extra." });
  }
});

// DELETE /info-extras/:id — hard delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("DELETE FROM info_extras WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Informação extra não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao excluir informação extra." });
  }
});

module.exports = router;
