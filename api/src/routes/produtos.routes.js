const express = require("express");
const router = express.Router();

const pool = require("../db");
const { authRequired, requireRole } = require("../middleware/auth");

// Tudo aqui exige ADMIN
router.use(authRequired, requireRole("ADMIN"));

// GET /admin/produtos?q=
router.get("/", async (req, res) => {
  try {
    const q = (req.query.q || "").toString().trim();
    if (!q) {
      const [rows] = await pool.query(
        "SELECT id, descricao, preco_venda FROM produtos ORDER BY descricao"
      );
      return res.json(rows);
    }

    const like = `%${q}%`;
    const [rows] = await pool.query(
      "SELECT id, descricao, preco_venda FROM produtos WHERE descricao LIKE ? OR id = ? ORDER BY descricao",
      [like, Number(q) || 0]
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
    const { descricao, preco_venda } = req.body;

    if (!descricao || preco_venda === undefined || preco_venda === null) {
      return res.status(400).json({ message: "Descrição e preço obrigatórios" });
    }

    const precoNum = Number(preco_venda);
    if (!Number.isFinite(precoNum) || precoNum <= 0) {
      return res.status(400).json({ message: "Preço inválido" });
    }

    const [result] = await pool.query(
      "INSERT INTO produtos (descricao, preco_venda) VALUES (?, ?)",
      [descricao, precoNum]
    );

    res.json({ id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao criar produto" });
  }
});

// PATCH /admin/produtos/:id
router.patch("/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { descricao, preco_venda } = req.body || {};

    if (!id) return res.status(400).json({ message: "ID inválido" });

    const updates = [];
    const params = [];

    if (descricao !== undefined) {
      if (!String(descricao).trim()) {
        return res.status(400).json({ message: "Descrição inválida" });
      }
      updates.push("descricao=?");
      params.push(String(descricao).trim());
    }

    if (preco_venda !== undefined) {
      const precoNum = Number(preco_venda);
      if (!Number.isFinite(precoNum) || precoNum <= 0) {
        return res.status(400).json({ message: "Preço inválido" });
      }
      updates.push("preco_venda=?");
      params.push(precoNum);
    }

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
    if (!id) return res.status(400).json({ message: "ID inválido" });

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
