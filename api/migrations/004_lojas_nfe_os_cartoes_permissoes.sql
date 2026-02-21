-- 004_lojas_nfe_os_cartoes_permissoes.sql
-- Lojas, cartoes/operadoras, permissoes, info fiscais, conversao UM,
-- tabela nutricional, info extras, notas fiscais, ordens de servico, pdv config

-- ===== LOJAS =====
CREATE TABLE IF NOT EXISTS lojas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  cnpj VARCHAR(18) DEFAULT NULL,
  inscricao_estadual VARCHAR(20) DEFAULT NULL,
  inscricao_municipal VARCHAR(20) DEFAULT NULL,
  endereco VARCHAR(255) DEFAULT NULL,
  numero VARCHAR(20) DEFAULT NULL,
  bairro VARCHAR(100) DEFAULT NULL,
  cidade VARCHAR(100) DEFAULT NULL,
  uf CHAR(2) DEFAULT NULL,
  cep VARCHAR(10) DEFAULT NULL,
  telefone VARCHAR(20) DEFAULT NULL,
  email VARCHAR(150) DEFAULT NULL,
  regime_tributario VARCHAR(50) DEFAULT 'SIMPLES_NACIONAL',
  cnae VARCHAR(20) DEFAULT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== CARTOES / OPERADORAS =====
CREATE TABLE IF NOT EXISTS cartoes_operadoras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(100) NOT NULL,
  bandeira VARCHAR(50) DEFAULT NULL,
  taxa_percentual DECIMAL(5,2) DEFAULT 0,
  dias_recebimento INT DEFAULT 30,
  ativo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== PERMISSOES =====
CREATE TABLE IF NOT EXISTS permissoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  perfil VARCHAR(30) NOT NULL,
  modulo VARCHAR(50) NOT NULL,
  ler TINYINT(1) NOT NULL DEFAULT 0,
  escrever TINYINT(1) NOT NULL DEFAULT 0,
  excluir TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_perfil_modulo (perfil, modulo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed ADMIN (tudo true)
INSERT IGNORE INTO permissoes (perfil, modulo, ler, escrever, excluir) VALUES
  ('ADMIN', 'Produtos', 1, 1, 1),
  ('ADMIN', 'Pessoas', 1, 1, 1),
  ('ADMIN', 'Vendas', 1, 1, 1),
  ('ADMIN', 'Caixas', 1, 1, 1),
  ('ADMIN', 'Estoque', 1, 1, 1),
  ('ADMIN', 'Relatorios', 1, 1, 1),
  ('ADMIN', 'NFe', 1, 1, 1),
  ('ADMIN', 'OS', 1, 1, 1),
  ('ADMIN', 'Backup', 1, 1, 1),
  ('ADMIN', 'Usuarios', 1, 1, 1),
  ('ADMIN', 'Lojas', 1, 1, 1),
  ('ADMIN', 'Cartoes', 1, 1, 1);

-- Seed OPERADOR (limitado)
INSERT IGNORE INTO permissoes (perfil, modulo, ler, escrever, excluir) VALUES
  ('OPERADOR', 'Produtos', 1, 0, 0),
  ('OPERADOR', 'Pessoas', 1, 1, 0),
  ('OPERADOR', 'Vendas', 1, 1, 0),
  ('OPERADOR', 'Caixas', 1, 1, 0),
  ('OPERADOR', 'Estoque', 1, 0, 0),
  ('OPERADOR', 'Relatorios', 1, 0, 0),
  ('OPERADOR', 'NFe', 0, 0, 0),
  ('OPERADOR', 'OS', 1, 1, 0),
  ('OPERADOR', 'Backup', 0, 0, 0),
  ('OPERADOR', 'Usuarios', 0, 0, 0),
  ('OPERADOR', 'Lojas', 0, 0, 0),
  ('OPERADOR', 'Cartoes', 0, 0, 0);

-- ===== INFO FISCAIS (por produto) =====
CREATE TABLE IF NOT EXISTS info_fiscais (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  ncm VARCHAR(10) DEFAULT NULL,
  cest VARCHAR(10) DEFAULT NULL,
  cfop VARCHAR(10) DEFAULT NULL,
  origem VARCHAR(5) DEFAULT '0',
  cst_icms VARCHAR(5) DEFAULT NULL,
  aliq_icms DECIMAL(5,2) DEFAULT 0,
  cst_pis VARCHAR(5) DEFAULT NULL,
  aliq_pis DECIMAL(5,4) DEFAULT 0,
  cst_cofins VARCHAR(5) DEFAULT NULL,
  aliq_cofins DECIMAL(5,4) DEFAULT 0,
  UNIQUE KEY uq_info_fiscal_produto (produto_id),
  CONSTRAINT fk_info_fiscal_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== CONVERSAO DE UNIDADE DE MEDIDA =====
CREATE TABLE IF NOT EXISTS conversao_um (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  um_origem VARCHAR(10) NOT NULL,
  um_destino VARCHAR(10) NOT NULL,
  fator_multiplicador DECIMAL(12,4) NOT NULL DEFAULT 1,
  CONSTRAINT fk_conversao_um_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== TABELA NUTRICIONAL =====
CREATE TABLE IF NOT EXISTS tabela_nutricional (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  porcao VARCHAR(50) DEFAULT NULL,
  unidade_porcao VARCHAR(20) DEFAULT 'g',
  energia_kcal DECIMAL(8,2) DEFAULT 0,
  carboidratos DECIMAL(8,2) DEFAULT 0,
  proteinas DECIMAL(8,2) DEFAULT 0,
  gorduras_totais DECIMAL(8,2) DEFAULT 0,
  gorduras_saturadas DECIMAL(8,2) DEFAULT 0,
  gorduras_trans DECIMAL(8,2) DEFAULT 0,
  fibras DECIMAL(8,2) DEFAULT 0,
  sodio DECIMAL(8,2) DEFAULT 0,
  UNIQUE KEY uq_nutri_produto (produto_id),
  CONSTRAINT fk_nutri_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== INFO EXTRAS (chave/valor por produto) =====
CREATE TABLE IF NOT EXISTS info_extras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  chave VARCHAR(100) NOT NULL,
  valor TEXT DEFAULT NULL,
  CONSTRAINT fk_info_extras_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== NOTAS FISCAIS =====
CREATE TABLE IF NOT EXISTS notas_fiscais (
  id INT AUTO_INCREMENT PRIMARY KEY,
  venda_id INT DEFAULT NULL,
  loja_id INT DEFAULT NULL,
  tipo VARCHAR(10) NOT NULL DEFAULT 'NFCE',
  serie VARCHAR(5) DEFAULT '1',
  numero VARCHAR(20) DEFAULT NULL,
  chave_acesso VARCHAR(44) DEFAULT NULL,
  protocolo VARCHAR(30) DEFAULT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
  xml_envio LONGTEXT DEFAULT NULL,
  xml_retorno LONGTEXT DEFAULT NULL,
  motivo_cancelamento TEXT DEFAULT NULL,
  data_emissao TIMESTAMP NULL DEFAULT NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_nf_venda FOREIGN KEY (venda_id) REFERENCES vendas(id),
  CONSTRAINT fk_nf_loja FOREIGN KEY (loja_id) REFERENCES lojas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== ORDENS DE SERVICO =====
CREATE TABLE IF NOT EXISTS ordens_servico (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pessoa_id INT DEFAULT NULL,
  usuario_id INT DEFAULT NULL,
  descricao VARCHAR(255) DEFAULT NULL,
  defeito_relatado TEXT DEFAULT NULL,
  solucao TEXT DEFAULT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
  prioridade VARCHAR(20) NOT NULL DEFAULT 'MEDIA',
  data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_previsao DATE DEFAULT NULL,
  data_conclusao TIMESTAMP NULL DEFAULT NULL,
  valor_orcamento DECIMAL(10,2) DEFAULT 0,
  valor_final DECIMAL(10,2) DEFAULT 0,
  observacoes TEXT DEFAULT NULL,
  CONSTRAINT fk_os_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id),
  CONSTRAINT fk_os_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== PDV CONFIG (personalizacao por usuario) =====
CREATE TABLE IF NOT EXISTS pdv_config (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  cor_primaria VARCHAR(20) DEFAULT '#00D4AA',
  cor_secundaria VARCHAR(20) DEFAULT '#00A885',
  cor_borda VARCHAR(20) DEFAULT '#2A2A4A',
  cor_fundo VARCHAR(20) DEFAULT '#1A1A2E',
  imagem_fundo_url TEXT DEFAULT NULL,
  tema VARCHAR(30) DEFAULT 'padrao',
  UNIQUE KEY uq_pdv_config_usuario (usuario_id),
  CONSTRAINT fk_pdv_config_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
