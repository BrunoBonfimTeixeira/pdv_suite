// src/routes/admin_produtos.routes.js
const express = require("express");
const router = express.Router();
const pool = require("../db");

console.log("? admin_produtos.routes.js CARREGADO");

// GET /admin/produtos?q=
// GET /admin/produtos
router.get("/", async (req, res) => {
  try {
    const q = (req.query.q || "").toString().trim();

    if (!q) {
      const [rows] = await pool.query(
        "SELECT id, descricao, preco_venda, codigo_barras, preco_custo, markup, margem, ativo FROM produtos ORDER BY id DESC"
      );
      return res.json(rows);
    }

    const like = `%${q}%`;
    const n = Number(q) || 0;

    const [rows] = await pool.query(
      `SELECT id, descricao, preco_venda, codigo_barras, preco_custo, markup, margem, ativo
       FROM produtos
       WHERE descricao LIKE ?
          OR codigo_barras = ?
          OR id = ?
       ORDER BY id DESC`,
      [like, q, n]
    );

    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao listar produtos" });
  }
});

// POST /admin/produtos
router.post("/", async (req, res) => {
  try {
    const {
      descricao,
      preco_venda,
      codigo_barras,
      preco_custo,
      markup,
      margem,
      ativo,
    } = req.body || {};

    if (!descricao || preco_venda === undefined || preco_venda === null) {
      return res.status(400).json({ message: "Descrição e preco_venda são obrigatórios." });
    }

    if (!codigo_barras || !String(codigo_barras).trim()) {
      return res.status(400).json({ message: "Código de barras é obrigatório." });
    }

    const [result] = await pool.query(
      `
      INSERT INTO produtos
        (descricao, preco_venda, codigo_barras, preco_custo, markup, margem, ativo)
      VALUES
        (?, ?, ?, ?, ?, ?, ?)
      `,
      [
        descricao,
        preco_venda,
        String(codigo_barras).trim(),
        preco_custo ?? null,
        markup ?? null,
        margem ?? null,
        ativo === undefined ? 1 : (ativo ? 1 : 0),
      ]
    );

    res.status(201).json({ id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao criar produto" });
  }
});

// PATCH /admin/produtos/:id
router.patch("/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);

    const {
      descricao,
      preco_venda,
      codigo_barras,
      preco_custo,
      markup,
      margem,
      ativo,
    } = req.body || {};

    const updates = [];
    const params = [];

    if (descricao !== undefined) { updates.push("descricao=?"); params.push(descricao); }
    if (preco_venda !== undefined) { updates.push("preco_venda=?"); params.push(preco_venda); }

    if (codigo_barras !== undefined) {
      const cb = String(codigo_barras).trim();
      if (!cb) return res.status(400).json({ message: "Código de barras é obrigatório." });
      updates.push("codigo_barras=?");
      params.push(cb);
    }

    if (preco_custo !== undefined) { updates.push("preco_custo=?"); params.push(preco_custo); }
    if (markup !== undefined) { updates.push("markup=?"); params.push(markup); }
    if (margem !== undefined) { updates.push("margem=?"); params.push(margem); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) {
      return res.status(400).json({ message: "Nada para atualizar." });
    }

    params.push(id);

    const [result] = await pool.query(
      `UPDATE produtos SET ${updates.join(", ")} WHERE id=?`,
      params
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Produto não encontrado." });
    }

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao atualizar produto" });
  }
});

// DELETE /admin/produtos/:id
router.delete("/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);

    const [result] = await pool.query("DELETE FROM produtos WHERE id=?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Produto não encontrado." });
    }

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao remover produto" });
  }
});

module.exports = router;
