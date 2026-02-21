const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// Abrir caixa
router.post("/abrir", async (req, res) => {
  const { valorAbertura, observacoes } = req.body || {};
  const usuarioId = req.user.id;

  // Verificar se já tem caixa aberto para este usuário
  const [aberto] = await pool.query(
    "SELECT id FROM caixas WHERE usuario_id = ? AND status = 'ABERTO' LIMIT 1",
    [usuarioId]
  );
  if (aberto.length > 0) {
    return res.status(400).json({ message: "Já existe um caixa aberto para este usuário.", caixaId: aberto[0].id });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO caixas (usuario_id, data_abertura, valor_abertura, status, observacoes)
       VALUES (?, NOW(), ?, 'ABERTO', ?)`,
      [usuarioId, valorAbertura || 0, observacoes || null]
    );
    res.json({ caixaId: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao abrir caixa.", detail: String(e) });
  }
});

// Fechar caixa
router.post("/fechar", async (req, res) => {
  const { caixaId, valorFechamento, observacoes } = req.body || {};
  const usuarioId = req.user.id;

  if (!caixaId) return res.status(400).json({ message: "caixaId obrigatório." });

  try {
    // Buscar caixa aberto
    const [caixas] = await pool.query(
      "SELECT * FROM caixas WHERE id = ? AND usuario_id = ? AND status = 'ABERTO'",
      [caixaId, usuarioId]
    );
    if (caixas.length === 0) {
      return res.status(404).json({ message: "Caixa não encontrado ou já fechado." });
    }

    // Calcular valor do sistema (soma das vendas finalizadas neste caixa)
    const [totais] = await pool.query(
      "SELECT COALESCE(SUM(total_liquido), 0) AS total FROM vendas WHERE caixa_id = ? AND status = 'FINALIZADA'",
      [caixaId]
    );

    // Sangrias e suprimentos
    const [sangrias] = await pool.query(
      "SELECT COALESCE(SUM(CASE WHEN tipo='SANGRIA' THEN valor ELSE 0 END),0) AS total_sangrias, COALESCE(SUM(CASE WHEN tipo='SUPRIMENTO' THEN valor ELSE 0 END),0) AS total_suprimentos FROM sangrias_suprimentos WHERE caixa_id = ?",
      [caixaId]
    );

    const totalVendas = Number(totais[0].total);
    const totalSangrias = Number(sangrias[0].total_sangrias);
    const totalSuprimentos = Number(sangrias[0].total_suprimentos);
    const valorSistema = Number(caixas[0].valor_abertura) + totalVendas + totalSuprimentos - totalSangrias;
    const vFechamento = valorFechamento != null ? Number(valorFechamento) : valorSistema;
    const diferenca = vFechamento - valorSistema;

    await pool.query(
      `UPDATE caixas SET data_fechamento = NOW(), valor_fechamento = ?, valor_sistema = ?,
       diferenca = ?, status = 'FECHADO', observacoes = COALESCE(?, observacoes) WHERE id = ?`,
      [vFechamento, valorSistema, diferenca, observacoes || null, caixaId]
    );

    res.json({ ok: true, valorSistema, valorFechamento: vFechamento, diferenca, totalSangrias, totalSuprimentos });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao fechar caixa.", detail: String(e) });
  }
});

// POST /caixas/sangria
router.post("/sangria", async (req, res) => {
  const { caixaId, valor, motivo } = req.body || {};
  if (!caixaId || !valor) return res.status(400).json({ message: "caixaId e valor obrigatórios." });

  try {
    const [result] = await pool.query(
      "INSERT INTO sangrias_suprimentos (caixa_id, usuario_id, tipo, valor, motivo) VALUES (?, ?, 'SANGRIA', ?, ?)",
      [caixaId, req.user.id, valor, motivo || null]
    );
    res.json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao registrar sangria." });
  }
});

// POST /caixas/suprimento
router.post("/suprimento", async (req, res) => {
  const { caixaId, valor, motivo } = req.body || {};
  if (!caixaId || !valor) return res.status(400).json({ message: "caixaId e valor obrigatórios." });

  try {
    const [result] = await pool.query(
      "INSERT INTO sangrias_suprimentos (caixa_id, usuario_id, tipo, valor, motivo) VALUES (?, ?, 'SUPRIMENTO', ?, ?)",
      [caixaId, req.user.id, valor, motivo || null]
    );
    res.json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao registrar suprimento." });
  }
});

// GET /caixas/:id/sangrias-suprimentos
router.get("/:id/sangrias-suprimentos", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT ss.*, u.nome AS usuario_nome
       FROM sangrias_suprimentos ss
       LEFT JOIN usuarios u ON u.id = ss.usuario_id
       WHERE ss.caixa_id = ?
       ORDER BY ss.id DESC`,
      [req.params.id]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar sangrias/suprimentos." });
  }
});

// Buscar caixa aberto do usuário logado
router.get("/aberto", async (req, res) => {
  const usuarioId = req.user.id;
  try {
    const [rows] = await pool.query(
      "SELECT * FROM caixas WHERE usuario_id = ? AND status = 'ABERTO' ORDER BY id DESC LIMIT 1",
      [usuarioId]
    );
    if (rows.length === 0) return res.json(null);
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar caixa aberto." });
  }
});

// Listar caixas (admin)
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.*, u.nome AS usuario_nome
      FROM caixas c
      LEFT JOIN usuarios u ON u.id = c.usuario_id
      ORDER BY c.id DESC
      LIMIT 200
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar caixas." });
  }
});

// Buscar caixa por ID
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT c.*, u.nome AS usuario_nome
       FROM caixas c LEFT JOIN usuarios u ON u.id = c.usuario_id
       WHERE c.id = ?`,
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ message: "Caixa não encontrado." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar caixa." });
  }
});

module.exports = router;
