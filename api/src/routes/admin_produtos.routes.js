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
        `SELECT p.id, p.descricao, p.preco_venda, p.codigo_barras, p.preco_custo, p.markup, p.margem, p.ativo,
                p.categoria_id, p.unidade_medida, p.estoque_atual, p.estoque_minimo,
                c.descricao AS categoria_descricao
         FROM produtos p
         LEFT JOIN categorias c ON c.id = p.categoria_id
         ORDER BY p.id DESC`
      );
      return res.json(rows);
    }

    const like = `%${q}%`;
    const n = Number(q) || 0;

    const [rows] = await pool.query(
      `SELECT p.id, p.descricao, p.preco_venda, p.codigo_barras, p.preco_custo, p.markup, p.margem, p.ativo,
              p.categoria_id, p.unidade_medida, p.estoque_atual, p.estoque_minimo,
              c.descricao AS categoria_descricao
       FROM produtos p
       LEFT JOIN categorias c ON c.id = p.categoria_id
       WHERE p.descricao LIKE ?
          OR p.codigo_barras = ?
          OR p.id = ?
       ORDER BY p.id DESC`,
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
      categoria_id,
      unidade_medida,
      estoque_atual,
      estoque_minimo,
    } = req.body || {};

    if (!descricao || preco_venda === undefined || preco_venda === null) {
      return res.status(400).json({ message: "Descricao e preco_venda sao obrigatorios." });
    }

    if (Number(preco_venda) < 0) {
      return res.status(400).json({ message: "Preco de venda nao pode ser negativo." });
    }

    if (preco_custo !== undefined && preco_custo !== null && Number(preco_custo) < 0) {
      return res.status(400).json({ message: "Preco de custo nao pode ser negativo." });
    }

    if (!codigo_barras || !String(codigo_barras).trim()) {
      return res.status(400).json({ message: "Codigo de barras e obrigatorio." });
    }

    const [result] = await pool.query(
      `INSERT INTO produtos
        (descricao, preco_venda, codigo_barras, preco_custo, markup, margem, ativo, categoria_id, unidade_medida, estoque_atual, estoque_minimo)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        descricao,
        preco_venda,
        String(codigo_barras).trim(),
        preco_custo ?? null,
        markup ?? null,
        margem ?? null,
        ativo === undefined ? 1 : (ativo ? 1 : 0),
        categoria_id || 1,
        unidade_medida || 'UN',
        estoque_atual || 0,
        estoque_minimo || 0,
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
    if (preco_venda !== undefined) {
      if (Number(preco_venda) < 0) return res.status(400).json({ message: "Preco de venda nao pode ser negativo." });
      updates.push("preco_venda=?"); params.push(preco_venda);
    }

    if (codigo_barras !== undefined) {
      const cb = String(codigo_barras).trim();
      if (!cb) return res.status(400).json({ message: "C�digo de barras � obrigat�rio." });
      updates.push("codigo_barras=?");
      params.push(cb);
    }

    if (preco_custo !== undefined) { updates.push("preco_custo=?"); params.push(preco_custo); }
    if (markup !== undefined) { updates.push("markup=?"); params.push(markup); }
    if (margem !== undefined) { updates.push("margem=?"); params.push(margem); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }
    if (req.body.categoria_id !== undefined) { updates.push("categoria_id=?"); params.push(req.body.categoria_id); }
    if (req.body.unidade_medida !== undefined) { updates.push("unidade_medida=?"); params.push(req.body.unidade_medida); }
    if (req.body.estoque_atual !== undefined) { updates.push("estoque_atual=?"); params.push(req.body.estoque_atual); }
    if (req.body.estoque_minimo !== undefined) { updates.push("estoque_minimo=?"); params.push(req.body.estoque_minimo); }

    if (!updates.length) {
      return res.status(400).json({ message: "Nada para atualizar." });
    }

    params.push(id);

    const [result] = await pool.query(
      `UPDATE produtos SET ${updates.join(", ")} WHERE id=?`,
      params
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Produto n�o encontrado." });
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
      return res.status(404).json({ message: "Produto n�o encontrado." });
    }

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao remover produto" });
  }
});

module.exports = router;
