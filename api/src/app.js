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
const corsOrigin = process.env.CORS_ORIGIN || "*";
app.use(
  cors({
    origin: corsOrigin === "*" ? true : corsOrigin,
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



// 404
app.use((req, res) => res.status(404).json({ message: "Rota não encontrada." }));

const port = Number(process.env.PORT || 3000);
app.listen(port, "0.0.0.0", () => {
  console.log(`✅ API rodando na porta ${port}`);
});
