const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../db");

const router = express.Router();

router.post("/login", async (req, res) => {
  try {
    const { login, senha } = req.body || {};
    if (!login || !senha) return res.status(400).json({ message: "login e senha são obrigatórios." });

    const [rows] = await pool.query(
      "SELECT id, nome, login, senha_hash, perfil, ativo FROM usuarios WHERE login = ? LIMIT 1",
      [login]
    );

    if (!rows.length) return res.status(401).json({ message: "Credenciais inválidas." });

    const u = rows[0];
    if (u.ativo !== 1) return res.status(403).json({ message: "Usuário inativo." });

    const ok = await bcrypt.compare(senha, u.senha_hash);
    if (!ok) return res.status(401).json({ message: "Credenciais inválidas." });

    const token = jwt.sign(
      { id: u.id, nome: u.nome, perfil: u.perfil },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || "8h" }
    );

    return res.json({
      token,
      usuario: { id: u.id, nome: u.nome, login: u.login, perfil: u.perfil, ativo: true }
    });
  } catch (e) {
    return res.status(500).json({ message: "Erro no login.", detail: String(e) });
  }
});

module.exports = router;
