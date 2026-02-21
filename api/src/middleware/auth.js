const jwt = require("jsonwebtoken");

function authRequired(req, res, next) {
  const header = req.headers.authorization || "";
  const [type, token] = header.split(" ");

  if (type !== "Bearer" || !token) {
    return res.status(401).json({ message: "Nao autenticado." });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload; // { id, nome, perfil, ... }
    return next();
  } catch (e) {
    return res.status(401).json({ message: "Token invalido ou expirado." });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user?.perfil) return res.status(401).json({ message: "Nao autenticado." });
    if (!roles.includes(req.user.perfil)) {
      return res.status(403).json({ message: "Acesso negado." });
    }
    next();
  };
}

const adminRequired = requireRole("ADMIN");

module.exports = { authRequired, requireRole, adminRequired };
