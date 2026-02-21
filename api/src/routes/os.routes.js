const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /os — listar com filtros
router.get("/", async (req, res) => {
  try {
    const { status, prioridade, pessoa_id } = req.query;
    let sql = `
      SELECT os.*, p.nome AS pessoa_nome
      FROM ordens_servico os
      LEFT JOIN pessoas p ON p.id = os.pessoa_id
      WHERE 1=1
    `;
    const params = [];

    if (status) { sql += " AND os.status = ?"; params.push(status); }
    if (prioridade) { sql += " AND os.prioridade = ?"; params.push(prioridade); }
    if (pessoa_id) { sql += " AND os.pessoa_id = ?"; params.push(pessoa_id); }

    sql += " ORDER BY os.id DESC LIMIT 200";
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar ordens de serviço." });
  }
});

// GET /os/:id — buscar por id
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT os.*, p.nome AS pessoa_nome
       FROM ordens_servico os
       LEFT JOIN pessoas p ON p.id = os.pessoa_id
       WHERE os.id = ?`,
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ message: "Ordem de serviço não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar ordem de serviço." });
  }
});

// POST /os — criar (ADMIN)
router.post("/", adminRequired, async (req, res) => {
  try {
    const {
      pessoa_id, descricao, defeito_relatado, prioridade,
      data_previsao, valor_orcamento, observacoes
    } = req.body || {};

    if (!descricao) return res.status(400).json({ message: "Descrição é obrigatória." });

    const [result] = await pool.query(
      `INSERT INTO ordens_servico
        (pessoa_id, usuario_id, descricao, defeito_relatado, prioridade, data_previsao, valor_orcamento, observacoes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        pessoa_id || null,
        req.user.id,
        descricao,
        defeito_relatado || null,
        prioridade || "NORMAL",
        data_previsao || null,
        valor_orcamento || 0,
        observacoes || null
      ]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao criar ordem de serviço." });
  }
});

// PATCH /os/:id — atualizar (ADMIN)
router.patch("/:id", adminRequired, async (req, res) => {
  try {
    const {
      pessoa_id, descricao, defeito_relatado, prioridade,
      data_previsao, valor_orcamento, observacoes,
      status, solucao, valor_final, data_conclusao
    } = req.body || {};

    const updates = [];
    const params = [];

    if (pessoa_id !== undefined) { updates.push("pessoa_id=?"); params.push(pessoa_id); }
    if (descricao !== undefined) { updates.push("descricao=?"); params.push(descricao); }
    if (defeito_relatado !== undefined) { updates.push("defeito_relatado=?"); params.push(defeito_relatado); }
    if (prioridade !== undefined) { updates.push("prioridade=?"); params.push(prioridade); }
    if (data_previsao !== undefined) { updates.push("data_previsao=?"); params.push(data_previsao); }
    if (valor_orcamento !== undefined) { updates.push("valor_orcamento=?"); params.push(valor_orcamento); }
    if (observacoes !== undefined) { updates.push("observacoes=?"); params.push(observacoes); }
    if (status !== undefined) { updates.push("status=?"); params.push(status); }
    if (solucao !== undefined) { updates.push("solucao=?"); params.push(solucao); }
    if (valor_final !== undefined) { updates.push("valor_final=?"); params.push(valor_final); }
    if (data_conclusao !== undefined) { updates.push("data_conclusao=?"); params.push(data_conclusao); }

    if (!updates.length) return res.status(400).json({ message: "Nada para atualizar." });

    params.push(req.params.id);
    const [result] = await pool.query(`UPDATE ordens_servico SET ${updates.join(", ")} WHERE id=?`, params);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Ordem de serviço não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao atualizar ordem de serviço." });
  }
});

// DELETE /os/:id — hard delete (ADMIN)
router.delete("/:id", adminRequired, async (req, res) => {
  try {
    const [result] = await pool.query("DELETE FROM ordens_servico WHERE id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Ordem de serviço não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao excluir ordem de serviço." });
  }
});

module.exports = router;
