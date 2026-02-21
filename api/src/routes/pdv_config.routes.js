const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /pdv-config/minha-config — buscar config do usuário logado
router.get("/minha-config", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM pdv_config WHERE usuario_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      // Retornar defaults
      return res.json({
        usuario_id: req.user.id,
        cor_primaria: "#1976D2",
        cor_secundaria: "#424242",
        cor_borda: "#E0E0E0",
        cor_fundo: "#FFFFFF",
        imagem_fundo_url: null,
        tema: "light"
      });
    }

    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar configuração do PDV." });
  }
});

// POST /pdv-config — criar/atualizar config do usuário logado
router.post("/", async (req, res) => {
  try {
    const {
      cor_primaria, cor_secundaria, cor_borda,
      cor_fundo, imagem_fundo_url, tema
    } = req.body || {};

    const [result] = await pool.query(
      `INSERT INTO pdv_config
        (usuario_id, cor_primaria, cor_secundaria, cor_borda, cor_fundo, imagem_fundo_url, tema)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
        cor_primaria=VALUES(cor_primaria), cor_secundaria=VALUES(cor_secundaria),
        cor_borda=VALUES(cor_borda), cor_fundo=VALUES(cor_fundo),
        imagem_fundo_url=VALUES(imagem_fundo_url), tema=VALUES(tema)`,
      [
        req.user.id,
        cor_primaria || "#1976D2",
        cor_secundaria || "#424242",
        cor_borda || "#E0E0E0",
        cor_fundo || "#FFFFFF",
        imagem_fundo_url || null,
        tema || "light"
      ]
    );
    res.status(201).json({ ok: true, id: result.insertId || req.user.id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao salvar configuração do PDV." });
  }
});

module.exports = router;
