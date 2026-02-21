const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /lojas — listar todas (ativas por padrão)
router.get("/", async (req, res) => {
  try {
    const ativo = req.query.ativo !== undefined ? req.query.ativo : 1;
    const [rows] = await pool.query(
      "SELECT * FROM lojas WHERE ativo = ? ORDER BY nome",
      [ativo]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar lojas." });
  }
});

// GET /lojas/:id
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM lojas WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Loja não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar loja." });
  }
});

// POST /lojas — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const {
      nome, cnpj, inscricao_estadual, inscricao_municipal,
      endereco, numero, bairro, cidade, uf, cep,
      telefone, email, regime_tributario, cnae, ativo
    } = req.body || {};

    if (!nome) return res.status(400).json({ message: "Nome é obrigatório." });

    const [result] = await pool.query(
      `INSERT INTO lojas
        (nome, cnpj, inscricao_estadual, inscricao_municipal,
         endereco, numero, bairro, cidade, uf, cep,
         telefone, email, regime_tributario, cnae, ativo)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        nome, cnpj || null, inscricao_estadual || null, inscricao_municipal || null,
        endereco || null, numero || null, bairro || null, cidade || null, uf || null, cep || null,
        telefone || null, email || null, regime_tributario || null, cnae || null,
        ativo !== undefined ? (ativo ? 1 : 0) : 1
      ]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar loja." });
  }
});

// PATCH /lojas/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const {
      nome, cnpj, inscricao_estadual, inscricao_municipal,
      endereco, numero, bairro, cidade, uf, cep,
      telefone, email, regime_tributario, cnae, ativo
    } = req.body || {};

    const updates = [];
    const params = [];

    if (nome !== undefined) { updates.push("nome=?"); params.push(nome); }
    if (cnpj !== undefined) { updates.push("cnpj=?"); params.push(cnpj); }
    if (inscricao_estadual !== undefined) { updates.push("inscricao_estadual=?"); params.push(inscricao_estadual); }
    if (inscricao_municipal !== undefined) { updates.push("inscricao_municipal=?"); params.push(inscricao_municipal); }
    if (endereco !== undefined) { updates.push("endereco=?"); params.push(endereco); }
    if (numero !== undefined) { updates.push("numero=?"); params.push(numero); }
    if (bairro !== undefined) { updates.push("bairro=?"); params.push(bairro); }
    if (cidade !== undefined) { updates.push("cidade=?"); params.push(cidade); }
    if (uf !== undefined) { updates.push("uf=?"); params.push(uf); }
    if (cep !== undefined) { updates.push("cep=?"); params.push(cep); }
    if (telefone !== undefined) { updates.push("telefone=?"); params.push(telefone); }
    if (email !== undefined) { updates.push("email=?"); params.push(email); }
    if (regime_tributario !== undefined) { updates.push("regime_tributario=?"); params.push(regime_tributario); }
    if (cnae !== undefined) { updates.push("cnae=?"); params.push(cnae); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE lojas SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Loja não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar loja." });
  }
});

// DELETE /lojas/:id — soft delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("UPDATE lojas SET ativo=0 WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Loja não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao remover loja." });
  }
});

module.exports = router;
