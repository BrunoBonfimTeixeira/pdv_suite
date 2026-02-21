const express = require("express");
const pool = require("../db");
const { authRequired, adminRequired } = require("../middleware/auth");
const { execSync } = require("child_process");

const router = express.Router();
router.use(authRequired);
router.use(adminRequired);

// GET /backup/info — informações do banco de dados (ADMIN)
router.get("/info", async (req, res) => {
  try {
    const dbName = process.env.DB_NAME;

    // Tamanho total do banco
    const [sizeRows] = await pool.query(
      `SELECT
        SUM(data_length + index_length) AS tamanho_bytes,
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS tamanho_mb
       FROM information_schema.TABLES
       WHERE table_schema = ?`,
      [dbName]
    );

    // Contagem de tabelas
    const [tableCount] = await pool.query(
      `SELECT COUNT(*) AS total_tabelas
       FROM information_schema.TABLES
       WHERE table_schema = ?`,
      [dbName]
    );

    // Linhas por tabela
    const [tableRows] = await pool.query(
      `SELECT table_name, table_rows,
        ROUND((data_length + index_length) / 1024 / 1024, 2) AS tamanho_mb
       FROM information_schema.TABLES
       WHERE table_schema = ?
       ORDER BY table_rows DESC`,
      [dbName]
    );

    res.json({
      database: dbName,
      tamanho_bytes: sizeRows[0].tamanho_bytes || 0,
      tamanho_mb: sizeRows[0].tamanho_mb || 0,
      total_tabelas: tableCount[0].total_tabelas || 0,
      tabelas: tableRows
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao obter informações do banco." });
  }
});

// GET /backup/export — exportar dump SQL (ADMIN)
router.get("/export", async (req, res) => {
  try {
    const host = process.env.DB_HOST || "localhost";
    const port = process.env.DB_PORT || "3306";
    const user = process.env.DB_USER;
    const pass = process.env.DB_PASS;
    const dbName = process.env.DB_NAME;

    const cmd = `mysqldump -h ${host} -P ${port} -u ${user}${pass ? ` -p${pass}` : ""} ${dbName}`;
    const sqlDump = execSync(cmd, { maxBuffer: 100 * 1024 * 1024, encoding: "utf-8" });

    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    res.set("Content-Type", "text/plain; charset=utf-8");
    res.set("Content-Disposition", `attachment; filename="backup_${dbName}_${timestamp}.sql"`);
    res.send(sqlDump);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Erro ao exportar backup.", detail: String(e) });
  }
});

module.exports = router;
