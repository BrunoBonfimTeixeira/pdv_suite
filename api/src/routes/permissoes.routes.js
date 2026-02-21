const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /permissoes — listar todas ou filtrar por perfil
router.get("/", async (req, res) => {
  try {
    const { perfil } = req.query;
    let sql = "SELECT * FROM permissoes WHERE 1=1";
    const params = [];

    if (perfil) {
      sql += " AND perfil = ?";
      params.push(perfil);
    }

    sql += " ORDER BY perfil, modulo";
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar permissões." });
  }
});

// PATCH /permissoes/:id — atualizar permissões de módulo (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { ler, escrever, excluir } = req.body || {};
    const updates = [];
    const params = [];

    if (ler !== undefined) { updates.push("ler=?"); params.push(ler ? 1 : 0); }
    if (escrever !== undefined) { updates.push("escrever=?"); params.push(escrever ? 1 : 0); }
    if (excluir !== undefined) { updates.push("excluir=?"); params.push(excluir ? 1 : 0); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE permissoes SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Permissão não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar permissão." });
  }
});

module.exports = router;
