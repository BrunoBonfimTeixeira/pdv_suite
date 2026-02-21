-- 003_categorias_estoque_sangrias_descontos.sql
-- Categorias de produto, controle de estoque, sangrias/suprimentos, descontos

-- ===== CATEGORIAS =====
CREATE TABLE IF NOT EXISTS categorias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(100) NOT NULL,
  cor VARCHAR(20) DEFAULT '#607D8B',
  icone VARCHAR(50) DEFAULT 'category',
  ativo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO categorias (id, descricao, cor, icone) VALUES
  (1, 'Geral',       '#607D8B', 'category'),
  (2, 'Bebidas',     '#2196F3', 'local_drink'),
  (3, 'Frios',       '#00BCD4', 'ac_unit'),
  (4, 'Padaria',     '#FF9800', 'bakery_dining'),
  (5, 'Limpeza',     '#4CAF50', 'cleaning_services'),
  (6, 'Hortifruti',  '#8BC34A', 'eco');

-- ===== MOVIMENTOS DE ESTOQUE =====
CREATE TABLE IF NOT EXISTS movimentos_estoque (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  tipo VARCHAR(20) NOT NULL, -- ENTRADA, SAIDA, AJUSTE, VENDA, CANCELAMENTO
  quantidade DECIMAL(12,3) NOT NULL,
  estoque_anterior DECIMAL(12,3) NOT NULL DEFAULT 0,
  estoque_posterior DECIMAL(12,3) NOT NULL DEFAULT 0,
  motivo VARCHAR(255) DEFAULT NULL,
  usuario_id INT NOT NULL,
  referencia_id INT DEFAULT NULL,
  referencia_tipo VARCHAR(30) DEFAULT NULL, -- VENDA, AJUSTE_MANUAL, etc
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_estoque_produto FOREIGN KEY (produto_id) REFERENCES produtos(id),
  CONSTRAINT fk_mov_estoque_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== SANGRIAS E SUPRIMENTOS =====
CREATE TABLE IF NOT EXISTS sangrias_suprimentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  caixa_id INT NOT NULL,
  usuario_id INT NOT NULL,
  tipo VARCHAR(20) NOT NULL, -- SANGRIA, SUPRIMENTO
  valor DECIMAL(10,2) NOT NULL,
  motivo VARCHAR(255) DEFAULT NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sangria_caixa FOREIGN KEY (caixa_id) REFERENCES caixas(id),
  CONSTRAINT fk_sangria_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===== ALTER PRODUTOS: categoria, unidade, estoque =====
ALTER TABLE produtos ADD COLUMN categoria_id INT DEFAULT 1;
ALTER TABLE produtos ADD COLUMN unidade_medida VARCHAR(10) DEFAULT 'UN';
ALTER TABLE produtos ADD COLUMN estoque_atual DECIMAL(12,3) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN estoque_minimo DECIMAL(12,3) DEFAULT 0;

-- FK categoria (safe: default 1 = Geral, que foi inserido acima)
ALTER TABLE produtos ADD CONSTRAINT fk_produtos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id);

-- ===== ALTER VENDA_ITENS: descontos por item =====
ALTER TABLE venda_itens ADD COLUMN desconto_percentual DECIMAL(5,2) DEFAULT 0;
ALTER TABLE venda_itens ADD COLUMN desconto_valor DECIMAL(10,2) DEFAULT 0;

-- ===== ALTER VENDAS: observacoes =====
ALTER TABLE vendas ADD COLUMN observacoes TEXT DEFAULT NULL;
