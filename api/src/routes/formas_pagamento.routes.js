const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET — listar formas de pagamento ativas
router.get("/", async (req, res) => {
  try {
    const all = req.query.all === "1";
    const sql = all
      ? "SELECT * FROM formas_pagamento ORDER BY id ASC"
      : "SELECT * FROM formas_pagamento WHERE ativo = 1 ORDER BY id ASC";
    const [rows] = await pool.query(sql);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar formas de pagamento." });
  }
});

// POST — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const { descricao, tipo, ativo } = req.body || {};
    if (!descricao) return res.status(400).json({ message: "Descricao obrigatoria." });

    const [result] = await pool.query(
      "INSERT INTO formas_pagamento (descricao, tipo, ativo) VALUES (?, ?, ?)",
      [descricao, tipo || "OUTROS", ativo !== undefined ? (ativo ? 1 : 0) : 1]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar forma de pagamento." });
  }
});

// PATCH — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { descricao, tipo, ativo } = req.body || {};
    const updates = [];
    const params = [];

    if (descricao !== undefined) { updates.push("descricao=?"); params.push(descricao); }
    if (tipo !== undefined) { updates.push("tipo=?"); params.push(tipo); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE formas_pagamento SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Forma nao encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar forma de pagamento." });
  }
});

// DELETE — soft delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("UPDATE formas_pagamento SET ativo=0 WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Forma nao encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao remover forma de pagamento." });
  }
});

module.exports = router;
