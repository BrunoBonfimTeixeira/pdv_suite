const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// Listar formas de pagamento ativas
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM formas_pagamento WHERE ativo = 1 ORDER BY id ASC"
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar formas de pagamento." });
  }
});

module.exports = router;
