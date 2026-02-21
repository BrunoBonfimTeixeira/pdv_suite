const bcrypt = require("bcryptjs");
const pool = require("./db");

const ADMIN_DEFAULT = {
  nome: "Administrador",
  login: "admin",
  senha: "admin123",
  perfil: "ADMIN",
};

async function seed() {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      "SELECT id FROM usuarios WHERE login = ?",
      [ADMIN_DEFAULT.login]
    );

    if (rows.length > 0) {
      console.log(`Usuario "${ADMIN_DEFAULT.login}" ja existe (id=${rows[0].id}). Nenhuma alteracao feita.`);
      return;
    }

    const hash = await bcrypt.hash(ADMIN_DEFAULT.senha, 10);

    await conn.query(
      "INSERT INTO usuarios (nome, login, senha_hash, perfil, ativo) VALUES (?, ?, ?, ?, 1)",
      [ADMIN_DEFAULT.nome, ADMIN_DEFAULT.login, hash, ADMIN_DEFAULT.perfil]
    );

    console.log("Usuario admin criado com sucesso!");
    console.log(`  Login: ${ADMIN_DEFAULT.login}`);
    console.log(`  Senha: ${ADMIN_DEFAULT.senha}`);
    console.log("  IMPORTANTE: troque a senha em producao!");
  } finally {
    conn.release();
    await pool.end();
  }
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Erro ao criar seed:", err);
    process.exit(1);
  });
