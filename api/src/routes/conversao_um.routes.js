const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /conversao-um/produto/:produtoId — listar por produto
router.get("/produto/:produtoId", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM conversao_um WHERE produto_id = ? ORDER BY id",
      [req.params.produtoId]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar conversões de unidade." });
  }
});

// POST /conversao-um — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const { produto_id, um_origem, um_destino, fator_multiplicador } = req.body || {};
    if (!produto_id || !um_origem || !um_destino || fator_multiplicador === undefined) {
      return res.status(400).json({ message: "produto_id, um_origem, um_destino e fator_multiplicador são obrigatórios." });
    }

    const [result] = await pool.query(
      `INSERT INTO conversao_um (produto_id, um_origem, um_destino, fator_multiplicador)
       VALUES (?, ?, ?, ?)`,
      [produto_id, um_origem, um_destino, fator_multiplicador]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar conversão de unidade." });
  }
});

// PATCH /conversao-um/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { um_origem, um_destino, fator_multiplicador } = req.body || {};
    const updates = [];
    const params = [];

    if (um_origem !== undefined) { updates.push("um_origem=?"); params.push(um_origem); }
    if (um_destino !== undefined) { updates.push("um_destino=?"); params.push(um_destino); }
    if (fator_multiplicador !== undefined) { updates.push("fator_multiplicador=?"); params.push(fator_multiplicador); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE conversao_um SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Conversão não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar conversão de unidade." });
  }
});

// DELETE /conversao-um/:id — hard delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("DELETE FROM conversao_um WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Conversão não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao excluir conversão de unidade." });
  }
});

module.exports = router;
