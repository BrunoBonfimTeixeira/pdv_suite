const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// Listar pessoas
router.get("/", async (req, res) => {
  try {
    const q = req.query.q || "";
    const tipo = req.query.tipo || "";
    let sql = "SELECT * FROM pessoas WHERE 1=1";
    const params = [];

    if (q) {
      sql += " AND (nome LIKE ? OR cpf_cnpj LIKE ? OR telefone LIKE ? OR email LIKE ?)";
      const like = `%${q}%`;
      params.push(like, like, like, like);
    }
    if (tipo) {
      sql += " AND tipo = ?";
      params.push(tipo);
    }

    sql += " ORDER BY nome ASC LIMIT 200";

    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar pessoas." });
  }
});

// Buscar por ID
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM pessoas WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Pessoa não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar pessoa." });
  }
});

// Criar pessoa
router.post("/", async (req, res) => {
  const { nome, cpfCnpj, telefone, email, endereco, tipo } = req.body || {};
  if (!nome) return res.status(400).json({ message: "Nome é obrigatório." });

  try {
    const [result] = await pool.query(
      `INSERT INTO pessoas (nome, cpf_cnpj, telefone, email, endereco, tipo)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [nome, cpfCnpj || null, telefone || null, email || null, endereco || null, tipo || "CLIENTE"]
    );
    res.json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar pessoa.", detail: String(e) });
  }
});

// Atualizar pessoa
router.patch("/:id", async (req, res) => {
  const id = Number(req.params.id);
  const { nome, cpfCnpj, telefone, email, endereco, tipo, ativo } = req.body || {};

  const updates = [];
  const params = [];

  if (nome !== undefined) { updates.push("nome=?"); params.push(nome); }
  if (cpfCnpj !== undefined) { updates.push("cpf_cnpj=?"); params.push(cpfCnpj); }
  if (telefone !== undefined) { updates.push("telefone=?"); params.push(telefone); }
  if (email !== undefined) { updates.push("email=?"); params.push(email); }
  if (endereco !== undefined) { updates.push("endereco=?"); params.push(endereco); }
  if (tipo !== undefined) { updates.push("tipo=?"); params.push(tipo); }
  if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

  if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

  params.push(id);

  try {
    const [result] = await pool.query(
      `UPDATE pessoas SET ${updates.join(", ")} WHERE id=?`,
      params
    );
    if (result.affectedRows === 0) return res.status(404).json({ message: "Pessoa não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar pessoa.", detail: String(e) });
  }
});

// Deletar pessoa (soft: desativa)
router.delete("/:id", async (req, res) => {
  try {
    const [result] = await pool.query("UPDATE pessoas SET ativo = 0 WHERE id = ?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Pessoa não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao remover pessoa." });
  }
});

module.exports = router;
