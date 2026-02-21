const express = require("express");
const pool = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();
router.use(authRequired);

// GET /reports/dashboard — KPIs
router.get("/dashboard", async (req, res) => {
  try {
    const today = new Date().toISOString().slice(0, 10);

    // Vendas hoje
    const [vendasHoje] = await pool.query(
      `SELECT COUNT(*) AS qtd, COALESCE(SUM(total_liquido),0) AS receita
       FROM vendas WHERE status='FINALIZADA' AND DATE(data_hora) = ?`,
      [today]
    );

    // Vendas semana (últimos 7 dias)
    const [vendasSemana] = await pool.query(
      `SELECT COUNT(*) AS qtd, COALESCE(SUM(total_liquido),0) AS receita
       FROM vendas WHERE status='FINALIZADA' AND data_hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)`
    );

    // Vendas mês
    const [vendasMes] = await pool.query(
      `SELECT COUNT(*) AS qtd, COALESCE(SUM(total_liquido),0) AS receita
       FROM vendas WHERE status='FINALIZADA' AND MONTH(data_hora) = MONTH(NOW()) AND YEAR(data_hora) = YEAR(NOW())`
    );

    // Ticket médio mês
    const ticketMedio = vendasMes[0].qtd > 0 ? Number(vendasMes[0].receita) / Number(vendasMes[0].qtd) : 0;

    // Top 5 produtos (mês)
    const [topProdutos] = await pool.query(
      `SELECT p.descricao, SUM(vi.quantidade) AS qtd_vendida, SUM(vi.valor_total) AS total
       FROM venda_itens vi
       JOIN vendas v ON v.id = vi.venda_id
       JOIN produtos p ON p.id = vi.produto_id
       WHERE v.status='FINALIZADA' AND MONTH(v.data_hora)=MONTH(NOW()) AND YEAR(v.data_hora)=YEAR(NOW())
       GROUP BY vi.produto_id
       ORDER BY total DESC
       LIMIT 5`
    );

    // Estoque em alerta
    const [alertaEstoque] = await pool.query(
      "SELECT COUNT(*) AS qtd FROM produtos WHERE ativo=1 AND estoque_atual <= estoque_minimo AND estoque_minimo > 0"
    );

    res.json({
      hoje: { qtd: Number(vendasHoje[0].qtd), receita: Number(vendasHoje[0].receita) },
      semana: { qtd: Number(vendasSemana[0].qtd), receita: Number(vendasSemana[0].receita) },
      mes: { qtd: Number(vendasMes[0].qtd), receita: Number(vendasMes[0].receita) },
      ticketMedio,
      topProdutos,
      alertaEstoque: Number(alertaEstoque[0].qtd),
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao gerar dashboard." });
  }
});

// GET /reports/vendas-periodo?inicio=YYYY-MM-DD&fim=YYYY-MM-DD
router.get("/vendas-periodo", async (req, res) => {
  try {
    const { inicio, fim } = req.query;
    if (!inicio || !fim) return res.status(400).json({ message: "inicio e fim obrigatórios." });

    const [rows] = await pool.query(
      `SELECT DATE(data_hora) AS data, COUNT(*) AS qtd, SUM(total_liquido) AS receita
       FROM vendas WHERE status='FINALIZADA' AND DATE(data_hora) BETWEEN ? AND ?
       GROUP BY DATE(data_hora)
       ORDER BY data`,
      [inicio, fim]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar vendas por período." });
  }
});

// GET /reports/top-produtos?inicio=&fim=&limit=
router.get("/top-produtos", async (req, res) => {
  try {
    const { inicio, fim } = req.query;
    const limit = Number(req.query.limit) || 10;

    let where = "v.status='FINALIZADA'";
    const params = [];
    if (inicio && fim) {
      where += " AND DATE(v.data_hora) BETWEEN ? AND ?";
      params.push(inicio, fim);
    }

    const [rows] = await pool.query(
      `SELECT p.id, p.descricao, SUM(vi.quantidade) AS qtd_vendida, SUM(vi.valor_total) AS total
       FROM venda_itens vi
       JOIN vendas v ON v.id = vi.venda_id
       JOIN produtos p ON p.id = vi.produto_id
       WHERE ${where}
       GROUP BY vi.produto_id
       ORDER BY total DESC
       LIMIT ?`,
      [...params, limit]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar top produtos." });
  }
});

// GET /reports/por-categoria?inicio=&fim=
router.get("/por-categoria", async (req, res) => {
  try {
    const { inicio, fim } = req.query;
    let where = "v.status='FINALIZADA'";
    const params = [];
    if (inicio && fim) {
      where += " AND DATE(v.data_hora) BETWEEN ? AND ?";
      params.push(inicio, fim);
    }

    const [rows] = await pool.query(
      `SELECT COALESCE(c.descricao, 'Sem categoria') AS categoria,
              COUNT(DISTINCT v.id) AS qtd_vendas,
              SUM(vi.valor_total) AS total
       FROM venda_itens vi
       JOIN vendas v ON v.id = vi.venda_id
       JOIN produtos p ON p.id = vi.produto_id
       LEFT JOIN categorias c ON c.id = p.categoria_id
       WHERE ${where}
       GROUP BY p.categoria_id
       ORDER BY total DESC`,
      params
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar por categoria." });
  }
});

// GET /reports/por-pagamento?inicio=&fim=
router.get("/por-pagamento", async (req, res) => {
  try {
    const { inicio, fim } = req.query;
    let where = "v.status='FINALIZADA'";
    const params = [];
    if (inicio && fim) {
      where += " AND DATE(v.data_hora) BETWEEN ? AND ?";
      params.push(inicio, fim);
    }

    const [rows] = await pool.query(
      `SELECT fp.descricao AS forma, fp.tipo, SUM(vp.valor) AS total, COUNT(*) AS qtd
       FROM venda_pagamentos vp
       JOIN vendas v ON v.id = vp.venda_id
       JOIN formas_pagamento fp ON fp.id = vp.forma_pagamento_id
       WHERE ${where}
       GROUP BY vp.forma_pagamento_id
       ORDER BY total DESC`,
      params
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar por pagamento." });
  }
});

// GET /reports/por-operador?inicio=&fim=
router.get("/por-operador", async (req, res) => {
  try {
    const { inicio, fim } = req.query;
    let where = "v.status='FINALIZADA'";
    const params = [];
    if (inicio && fim) {
      where += " AND DATE(v.data_hora) BETWEEN ? AND ?";
      params.push(inicio, fim);
    }

    const [rows] = await pool.query(
      `SELECT u.nome AS operador, COUNT(*) AS qtd_vendas, SUM(v.total_liquido) AS total
       FROM vendas v
       JOIN usuarios u ON u.id = v.usuario_id
       WHERE ${where}
       GROUP BY v.usuario_id
       ORDER BY total DESC`,
      params
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao buscar por operador." });
  }
});

module.exports = router;
