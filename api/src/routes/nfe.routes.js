const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// POST /nfe/emitir — emitir nota fiscal (ADMIN)
router.post("/emitir", adminRequired, async (req, res) => {
  try {
    const { venda_id, loja_id, tipo } = req.body || {};
    if (!venda_id || !loja_id || !tipo) {
      return res.status(400).json({ message: "venda_id, loja_id e tipo são obrigatórios." });
    }

    // Buscar dados da venda
    const [vendas] = await pool.query("SELECT * FROM vendas WHERE id = ?", [venda_id]);
    if (vendas.length === 0) return res.status(404).json({ message: "Venda não encontrada." });

    const venda = vendas[0];

    // Gerar XML placeholder
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe">
  <NFe>
    <infNFe>
      <ide>
        <mod>${tipo === "NFCE" ? "65" : "55"}</mod>
        <tpEmis>1</tpEmis>
      </ide>
      <emit>
        <CNPJ>00000000000000</CNPJ>
      </emit>
      <det>
        <prod>
          <vProd>${venda.total_liquido}</vProd>
        </prod>
      </det>
      <total>
        <ICMSTot>
          <vNF>${venda.total_liquido}</vNF>
        </ICMSTot>
      </total>
    </infNFe>
  </NFe>
</nfeProc>`;

    const [result] = await pool.query(
      `INSERT INTO notas_fiscais (venda_id, loja_id, tipo, status, xml, usuario_id, data_emissao)
       VALUES (?, ?, ?, 'PENDENTE', ?, ?, NOW())`,
      [venda_id, loja_id, tipo, xml, req.user.id]
    );

    const [nota] = await pool.query("SELECT * FROM notas_fiscais WHERE id = ?", [result.insertId]);
    res.status(201).json(nota[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao emitir nota fiscal." });
  }
});

// GET /nfe — listar notas com filtros
router.get("/", async (req, res) => {
  try {
    const { status, tipo, de, ate } = req.query;
    let sql = "SELECT * FROM notas_fiscais WHERE 1=1";
    const params = [];

    if (status) { sql += " AND status = ?"; params.push(status); }
    if (tipo) { sql += " AND tipo = ?"; params.push(tipo); }
    if (de) { sql += " AND data_emissao >= ?"; params.push(de); }
    if (ate) { sql += " AND data_emissao <= ?"; params.push(ate); }

    sql += " ORDER BY id DESC LIMIT 200";
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao listar notas fiscais." });
  }
});

// GET /nfe/:id — buscar nota por id
router.get("/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM notas_fiscais WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Nota fiscal não encontrada." });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar nota fiscal." });
  }
});

// PATCH /nfe/:id/cancelar — cancelar nota (ADMIN)
router.patch("/:id/cancelar", adminRequired, async (req, res) => {
  try {
    const { motivo_cancelamento } = req.body || {};
    if (!motivo_cancelamento) {
      return res.status(400).json({ message: "motivo_cancelamento é obrigatório." });
    }

    const [result] = await pool.query(
      "UPDATE notas_fiscais SET status='CANCELADA', motivo_cancelamento=? WHERE id=?",
      [motivo_cancelamento, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ message: "Nota fiscal não encontrada." });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao cancelar nota fiscal." });
  }
});

// GET /nfe/:id/xml — retornar XML
router.get("/:id/xml", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT xml FROM notas_fiscais WHERE id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Nota fiscal não encontrada." });
    if (!rows[0].xml) return res.status(404).json({ message: "XML não disponível." });

    res.set("Content-Type", "application/xml");
    res.send(rows[0].xml);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar XML da nota fiscal." });
  }
});

module.exports = router;
