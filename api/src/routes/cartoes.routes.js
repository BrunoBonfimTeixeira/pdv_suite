const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /cartoes — listar todas (ativas por padrão)
router.get("/", async (req, res) => {
  try {
    const ativo = req.query.ativo !== undefined ? req.query.ativo : 1;
    const [rows] = await pool.query(
      "SELECT * FROM operadoras_cartao WHERE ativo = ? ORDER BY descricao",
      [ativo]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar operadoras de cartão." });
  }
});

// GET /cartoes/:id
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM operadoras_cartao WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Operadora não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar operadora." });
  }
});

// POST /cartoes — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const { descricao, bandeira, taxa_percentual, dias_recebimento, ativo } = req.body || {};
    if (!descricao) return res.status(400).json({ message: "Descrição é obrigatória." });

    const [result] = await pool.query(
      `INSERT INTO operadoras_cartao (descricao, bandeira, taxa_percentual, dias_recebimento, ativo)
       VALUES (?, ?, ?, ?, ?)`,
      [
        descricao,
        bandeira || null,
        taxa_percentual || 0,
        dias_recebimento || 30,
        ativo !== undefined ? (ativo ? 1 : 0) : 1
      ]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar operadora de cartão." });
  }
});

// PATCH /cartoes/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const { descricao, bandeira, taxa_percentual, dias_recebimento, ativo } = req.body || {};
    const updates = [];
    const params = [];

    if (descricao !== undefined) { updates.push("descricao=?"); params.push(descricao); }
    if (bandeira !== undefined) { updates.push("bandeira=?"); params.push(bandeira); }
    if (taxa_percentual !== undefined) { updates.push("taxa_percentual=?"); params.push(taxa_percentual); }
    if (dias_recebimento !== undefined) { updates.push("dias_recebimento=?"); params.push(dias_recebimento); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE operadoras_cartao SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Operadora não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar operadora de cartão." });
  }
});

// DELETE /cartoes/:id — soft delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("UPDATE operadoras_cartao SET ativo=0 WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Operadora não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao remover operadora de cartão." });
  }
});

module.exports = router;
