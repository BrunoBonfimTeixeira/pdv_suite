const express = require("express");
const router = express.Router();

const pool = require("../db");
const { authRequired, requireRole } = require("../middleware/auth");

// ? SUB-ROTAS (produtos admin)
const adminProdutosRoutes = require("./admin_produtos.routes");

// Tudo aqui exige ADMIN
console.log("? admin.routes.js CARREGADO");

router.use(authRequired, requireRole("ADMIN"));

// ? monta /admin/produtos
router.use("/produtos", adminProdutosRoutes);

// =========================
// USUÁRIOS
// =========================
router.get("/usuarios", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT id, nome, login, perfil, ativo, criado_em, atualizado_em
      FROM usuarios
      ORDER BY id DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao listar usuários" });
  }
});

router.patch("/usuarios/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { nome, login, perfil, ativo } = req.body || {};

    const updates = [];
    const params = [];

    if (nome !== undefined) { updates.push("nome=?"); params.push(nome); }
    if (login !== undefined) { updates.push("login=?"); params.push(login); }
    if (perfil !== undefined) { updates.push("perfil=?"); params.push(perfil); }
    if (ativo !== undefined) { updates.push("ativo=?"); params.push(ativo ? 1 : 0); }

    if (!updates.length) {
      return res.status(400).json({ message: "Nada para atualizar." });
    }

    params.push(id);

    const [result] = await pool.query(
      `UPDATE usuarios SET ${updates.join(", ")}, atualizado_em=NOW() WHERE id=?`,
      params
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Usuário não encontrado." });
    }

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao atualizar usuário" });
  }
});

module.exports = router;
