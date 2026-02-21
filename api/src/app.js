require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");

const authRoutes = require("./routes/auth.routes");
const adminRoutes = require("./routes/admin.routes");
const produtosRoutes = require("./routes/produtos.routes");
const vendasRoutes = require("./routes/vendas.routes");
const caixasRoutes = require("./routes/caixas.routes");
const pessoasRoutes = require("./routes/pessoas.routes");
const formasPagamentoRoutes = require("./routes/formas_pagamento.routes");
const categoriasRoutes = require("./routes/categorias.routes");
const estoqueRoutes = require("./routes/estoque.routes");
const reportsRoutes = require("./routes/reports.routes");
const lojasRoutes = require("./routes/lojas.routes");
const cartoesRoutes = require("./routes/cartoes.routes");
const permissoesRoutes = require("./routes/permissoes.routes");
const infoFiscaisRoutes = require("./routes/info_fiscais.routes");
const conversaoUmRoutes = require("./routes/conversao_um.routes");
const tabelaNutricionalRoutes = require("./routes/tabela_nutricional.routes");
const infoExtrasRoutes = require("./routes/info_extras.routes");
const nfeRoutes = require("./routes/nfe.routes");
const osRoutes = require("./routes/os.routes");
const pdvConfigRoutes = require("./routes/pdv_config.routes");
const backupRoutes = require("./routes/backup.routes");

const app = express();

// Segurança HTTP headers
app.use(helmet());

// JSON body
app.use(express.json({ limit: "1mb" }));

// Logs
app.use(morgan("dev"));

// Rate limit básico
app.use(
  rateLimit({
    windowMs: 60 * 1000,
    max: 120,
    standardHeaders: true,
    legacyHeaders: false
  })
);

// CORS controlado
const corsOrigin = process.env.CORS_ORIGIN || "http://localhost:*";
app.use(
  cors({
    origin: (origin, callback) => {
      // Permitir requests sem origin (mobile apps, curl, etc)
      if (!origin) return callback(null, true);
      const allowed = corsOrigin.split(",").map(s => s.trim());
      const isAllowed = allowed.some(pattern => {
        if (pattern === "*") return true;
        // Suporta wildcard simples: http://localhost:*
        const regex = new RegExp("^" + pattern.replace(/\*/g, ".*") + "$");
        return regex.test(origin);
      });
      if (isAllowed) return callback(null, true);
      callback(new Error("Bloqueado pelo CORS"));
    },
    credentials: true
  })
);

// Healthcheck
app.get("/", (req, res) => res.json({ ok: true, service: "pdv_api" }));

// Rotas
app.use("/auth", authRoutes);
app.use("/admin", adminRoutes);
app.use("/produtos", produtosRoutes);
app.use("/vendas", vendasRoutes);
app.use("/caixas", caixasRoutes);
app.use("/pessoas", pessoasRoutes);
app.use("/formas-pagamento", formasPagamentoRoutes);
app.use("/categorias", categoriasRoutes);
app.use("/estoque", estoqueRoutes);
app.use("/reports", reportsRoutes);
app.use("/lojas", lojasRoutes);
app.use("/cartoes", cartoesRoutes);
app.use("/permissoes", permissoesRoutes);
app.use("/info-fiscais", infoFiscaisRoutes);
app.use("/conversao-um", conversaoUmRoutes);
app.use("/tabela-nutricional", tabelaNutricionalRoutes);
app.use("/info-extras", infoExtrasRoutes);
app.use("/nfe", nfeRoutes);
app.use("/os", osRoutes);
app.use("/pdv-config", pdvConfigRoutes);
app.use("/backup", backupRoutes);

// 404
app.use((req, res) => res.status(404).json({ message: "Rota não encontrada." }));

const port = Number(process.env.PORT || 3000);
app.listen(port, "0.0.0.0", () => {
  console.log(`✅ API rodando na porta ${port}`);
});
