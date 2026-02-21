const fs = require("fs");
const path = require("path");
const pool = require("./db");

const MIGRATIONS_DIR = path.join(__dirname, "..", "migrations");

async function ensureMigrationsTable(conn) {
  await conn.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL UNIQUE,
      executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

async function getExecutedMigrations(conn) {
  const [rows] = await conn.query("SELECT name FROM _migrations ORDER BY id");
  return new Set(rows.map((r) => r.name));
}

function getPendingFiles(executed) {
  const files = fs
    .readdirSync(MIGRATIONS_DIR)
    .filter((f) => f.endsWith(".sql"))
    .sort();

  return files.filter((f) => !executed.has(f));
}

async function runMigration(conn, fileName) {
  const filePath = path.join(MIGRATIONS_DIR, fileName);
  const sql = fs.readFileSync(filePath, "utf-8");

  const statements = sql
    .split(";")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  for (const stmt of statements) {
    await conn.query(stmt);
  }

  await conn.query("INSERT INTO _migrations (name) VALUES (?)", [fileName]);
}

async function migrate() {
  const conn = await pool.getConnection();
  try {
    await ensureMigrationsTable(conn);

    const executed = await getExecutedMigrations(conn);
    const pending = getPendingFiles(executed);

    if (pending.length === 0) {
      console.log("Nenhuma migration pendente.");
      return;
    }

    console.log(`${pending.length} migration(s) pendente(s):`);

    for (const file of pending) {
      console.log(`  -> Executando: ${file} ...`);
      await conn.beginTransaction();
      try {
        await runMigration(conn, file);
        await conn.commit();
        console.log(`     OK`);
      } catch (err) {
        await conn.rollback();
        throw err;
      }
    }

    console.log("Migrations concluidas.");
  } finally {
    conn.release();
    await pool.end();
  }
}

migrate()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Erro ao executar migrations:", err);
    process.exit(1);
  });
