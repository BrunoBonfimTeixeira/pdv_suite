-- 002_caixas_pessoas_formas.sql
-- Novas tabelas: formas_pagamento, pessoas, caixas + ALTER vendas

-- Formas de pagamento
CREATE TABLE IF NOT EXISTS formas_pagamento (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(100) NOT NULL,
  tipo VARCHAR(50) NOT NULL DEFAULT 'OUTROS',
  ativo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed formas de pagamento
INSERT IGNORE INTO formas_pagamento (id, descricao, tipo, ativo) VALUES
  (1, 'Dinheiro',       'DINHEIRO', 1),
  (2, 'Cartao Credito', 'CREDITO',  1),
  (3, 'Cartao Debito',  'DEBITO',   1),
  (4, 'PIX',            'PIX',      1);

-- Pessoas (clientes/fornecedores)
CREATE TABLE IF NOT EXISTS pessoas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  cpf_cnpj VARCHAR(20) DEFAULT NULL,
  telefone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(255) DEFAULT NULL,
  endereco TEXT DEFAULT NULL,
  tipo VARCHAR(50) NOT NULL DEFAULT 'CLIENTE',
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Caixas (abertura/fechamento)
CREATE TABLE IF NOT EXISTS caixas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  data_abertura DATETIME NOT NULL,
  data_fechamento DATETIME DEFAULT NULL,
  valor_abertura DECIMAL(10,2) NOT NULL DEFAULT 0,
  valor_fechamento DECIMAL(10,2) DEFAULT NULL,
  valor_sistema DECIMAL(10,2) DEFAULT NULL,
  diferenca DECIMAL(10,2) DEFAULT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ABERTO',
  observacoes TEXT DEFAULT NULL,
  CONSTRAINT fk_caixas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Adicionar pessoa_id em vendas (nullable FK)
ALTER TABLE vendas ADD COLUMN pessoa_id INT DEFAULT NULL;

-- Limpar dados orfaos antes de adicionar FKs
DELETE FROM venda_pagamentos WHERE venda_id IN (SELECT id FROM vendas WHERE caixa_id NOT IN (SELECT id FROM caixas));

DELETE FROM venda_itens WHERE venda_id IN (SELECT id FROM vendas WHERE caixa_id NOT IN (SELECT id FROM caixas));

DELETE FROM vendas WHERE caixa_id NOT IN (SELECT id FROM caixas);

-- Agora adicionar as FKs
ALTER TABLE vendas ADD CONSTRAINT fk_vendas_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id);

ALTER TABLE vendas ADD CONSTRAINT fk_vendas_caixa FOREIGN KEY (caixa_id) REFERENCES caixas(id);

ALTER TABLE venda_pagamentos ADD CONSTRAINT fk_venda_pagamentos_forma FOREIGN KEY (forma_pagamento_id) REFERENCES formas_pagamento(id)
