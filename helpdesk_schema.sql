-- Painel de Chamados Internos - MVP (Kanban simples)
-- MySQL 8.0+ / Ubuntu
--
-- Modelo: Quadro -> Colunas -> Cartoes (chamados) + Comentarios.
-- O estado do chamado e a coluna em que ele esta (ex.: A fazer,
-- Em andamento, Concluido). Mover o cartao = trocar coluna_id/posicao.
--
-- posicao: use intervalos (1000, 2000, 3000...) para encaixar um item
-- entre dois outros sem reescrever a ordem de todos.

CREATE DATABASE IF NOT EXISTS helpdesk
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE helpdesk;

CREATE TABLE usuario (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(120)    NOT NULL,
  email       VARCHAR(150)    NOT NULL,
  senha_hash  VARCHAR(255)    NOT NULL,
  criado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario_email (email)
) ENGINE=InnoDB;

CREATE TABLE quadro (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  criador_id  BIGINT UNSIGNED NOT NULL,
  nome        VARCHAR(120)    NOT NULL,
  criado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_quadro_criador (criador_id),
  CONSTRAINT fk_quadro_criador
    FOREIGN KEY (criador_id) REFERENCES usuario (id)
) ENGINE=InnoDB;

CREATE TABLE coluna (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quadro_id  BIGINT UNSIGNED NOT NULL,
  nome       VARCHAR(100)    NOT NULL,
  posicao    INT             NOT NULL,
  PRIMARY KEY (id),
  KEY idx_coluna_quadro_posicao (quadro_id, posicao),
  CONSTRAINT fk_coluna_quadro
    FOREIGN KEY (quadro_id) REFERENCES quadro (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cartao (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  coluna_id       BIGINT UNSIGNED NOT NULL,
  solicitante_id  BIGINT UNSIGNED NOT NULL,
  responsavel_id  BIGINT UNSIGNED NULL,
  titulo          VARCHAR(200)    NOT NULL,
  descricao       TEXT            NULL,
  prioridade      ENUM('BAIXA','MEDIA','ALTA') NOT NULL DEFAULT 'MEDIA',
  posicao         INT             NOT NULL,
  criado_em       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_cartao_coluna_posicao (coluna_id, posicao),
  KEY idx_cartao_solicitante (solicitante_id),
  KEY idx_cartao_responsavel (responsavel_id),
  CONSTRAINT fk_cartao_coluna
    FOREIGN KEY (coluna_id) REFERENCES coluna (id),
  CONSTRAINT fk_cartao_solicitante
    FOREIGN KEY (solicitante_id) REFERENCES usuario (id),
  CONSTRAINT fk_cartao_responsavel
    FOREIGN KEY (responsavel_id) REFERENCES usuario (id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE comentario (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cartao_id  BIGINT UNSIGNED NOT NULL,
  autor_id   BIGINT UNSIGNED NOT NULL,
  texto      TEXT            NOT NULL,
  criado_em  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_comentario_cartao (cartao_id, criado_em),
  KEY idx_comentario_autor (autor_id),
  CONSTRAINT fk_comentario_cartao
    FOREIGN KEY (cartao_id) REFERENCES cartao (id) ON DELETE CASCADE,
  CONSTRAINT fk_comentario_autor
    FOREIGN KEY (autor_id) REFERENCES usuario (id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Dados de exemplo (pode remover). O senha_hash abaixo e apenas um
-- texto ilustrativo: na aplicacao, grave o hash real (bcrypt/argon2).
-- ---------------------------------------------------------------
INSERT INTO usuario (nome, email, senha_hash)
VALUES ('Usuario Demo', 'demo@empresa.com', 'substituir_pelo_hash_real');

INSERT INTO quadro (criador_id, nome) VALUES (1, 'Suporte de TI');

INSERT INTO coluna (quadro_id, nome, posicao) VALUES
  (1, 'A fazer',       1000),
  (1, 'Em andamento',  2000),
  (1, 'Concluido',     3000);

INSERT INTO cartao (coluna_id, solicitante_id, responsavel_id, titulo, descricao, prioridade, posicao)
VALUES
  (1, 1, NULL, 'Sem acesso a VPN', 'Erro ao conectar desde ontem.', 'ALTA', 1000),
  (2, 1, 1,    'Trocar mouse da mesa 12', NULL, 'BAIXA', 1000);

-- ---------------------------------------------------------------
-- Consultas essenciais
-- ---------------------------------------------------------------
-- Carregar o quadro inteiro (colunas e cartoes em ordem):
--   SELECT col.id AS coluna_id, col.nome AS coluna,
--          k.id AS cartao_id, k.titulo, k.prioridade, u.nome AS responsavel
--     FROM coluna col
--     LEFT JOIN cartao  k ON k.coluna_id = col.id
--     LEFT JOIN usuario u ON u.id = k.responsavel_id
--    WHERE col.quadro_id = 1
--    ORDER BY col.posicao, k.posicao;
--
-- Mover um cartao para outra coluna (entre dois cartoes: posicao intermediaria):
--   UPDATE cartao SET coluna_id = 3, posicao = 1500 WHERE id = 1;
