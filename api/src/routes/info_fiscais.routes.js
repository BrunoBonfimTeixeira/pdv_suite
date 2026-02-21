const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /info-fiscais/produto/:produtoId — buscar por produto
router.get("/produto/:produtoId", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM info_fiscais WHERE produto_id = ?",
      [req.params.produtoId]
    );
    if (rows.length === 0) return res.status(404).json({ message: "Informações fiscais não encontradas." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar informações fiscais." });
  }
});

// POST /info-fiscais — criar/upsert (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const {
      produto_id, ncm, cest, cfop, origem,
      cst_icms, aliq_icms, cst_pis, aliq_pis,
      cst_cofins, aliq_cofins
    } = req.body || {};

    if (!produto_id) return res.status(400).json({ message: "produto_id é obrigatório." });

    const [result] = await pool.query(
      `INSERT INTO info_fiscais
        (produto_id, ncm, cest, cfop, origem, cst_icms, aliq_icms, cst_pis, aliq_pis, cst_cofins, aliq_cofins)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
        ncm=VALUES(ncm), cest=VALUES(cest), cfop=VALUES(cfop), origem=VALUES(origem),
        cst_icms=VALUES(cst_icms), aliq_icms=VALUES(aliq_icms),
        cst_pis=VALUES(cst_pis), aliq_pis=VALUES(aliq_pis),
        cst_cofins=VALUES(cst_cofins), aliq_cofins=VALUES(aliq_cofins)`,
      [
        produto_id, ncm || null, cest || null, cfop || null, origem || null,
        cst_icms || null, aliq_icms || 0, cst_pis || null, aliq_pis || 0,
        cst_cofins || null, aliq_cofins || 0
      ]
    );
    res.status(201).json({ id: result.insertId || produto_id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao salvar informações fiscais." });
  }
});

// PATCH /info-fiscais/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const {
      ncm, cest, cfop, origem,
      cst_icms, aliq_icms, cst_pis, aliq_pis,
      cst_cofins, aliq_cofins
    } = req.body || {};

    const updates = [];
    const params = [];

    if (ncm !== undefined) { updates.push("ncm=?"); params.push(ncm); }
    if (cest !== undefined) { updates.push("cest=?"); params.push(cest); }
    if (cfop !== undefined) { updates.push("cfop=?"); params.push(cfop); }
    if (origem !== undefined) { updates.push("origem=?"); params.push(origem); }
    if (cst_icms !== undefined) { updates.push("cst_icms=?"); params.push(cst_icms); }
    if (aliq_icms !== undefined) { updates.push("aliq_icms=?"); params.push(aliq_icms); }
    if (cst_pis !== undefined) { updates.push("cst_pis=?"); params.push(cst_pis); }
    if (aliq_pis !== undefined) { updates.push("aliq_pis=?"); params.push(aliq_pis); }
    if (cst_cofins !== undefined) { updates.push("cst_cofins=?"); params.push(cst_cofins); }
    if (aliq_cofins !== undefined) { updates.push("aliq_cofins=?"); params.push(aliq_cofins); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE info_fiscais SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Informação fiscal não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar informações fiscais." });
  }
});

module.exports = router;
