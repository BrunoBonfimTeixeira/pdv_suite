const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /categorias — listar todas (ativas por padrão)
router.get("/", async (req, res) => {
  try {
    const ativo = req.query.ativo !== undefined ? req.query.ativo : 1;
    const [rows] = await pool.query(
      "SELECT * FROM categorias WHERE ativo = ? ORDER BY descricao",
      [ativo]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar categorias." });
  }
});

// GET /categorias/:id
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM categorias WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Categoria não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar categoria." });
  }
});

// POST /categorias — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const { descricao, cor, icone, ativo } = req.body || {};
    if (!descricao) return res.status(400).json({ message: "Descrição obrigatória." });

    const [result] = await pool.query(
      "INSERT INTO categorias (descricao, cor, icone, ativo) VALUES (?, ?, ?, ?)",
      [descricao, cor || "#607D8B", icone || "category", ativo !== undefined ? (ativo ? 1 : 0) : 1]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar categoria." });
  }
});

// PATCH /categorias/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { descricao, cor, icone, ativo } = req.body || {};
    const updates = [];
    const params = [];

    if (descricao !== undefined) { updates.push("descricao=?"); params.push(descricao); }
    if (cor !== undefined) { updates.push("cor=?"); params.push(cor); }
    if (icone !== undefined) { updates.push("icone=?"); params.push(icone); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE categorias SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Categoria não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar categoria." });
  }
});

// DELETE /categorias/:id — soft delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("UPDATE categorias SET ativo=0 WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Categoria não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao remover categoria." });
  }
});

module.exports = router;
