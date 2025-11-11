/*
01_create_entidades.sql
Entidades con dependencias: USUARIOS, CONVERSACIONES, MENSAJES (con triggers XOR), TICKETS
*/
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- Entidad: USUARIOS
-- ============================================
CREATE TABLE IF NOT EXISTS USUARIOS (
    id_usuario  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(120) NOT NULL,
    email       VARCHAR(190) NOT NULL,
    password    VARCHAR(100) NOT NULL,
    fecha_alta  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo      TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uk_usuarios_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Entidad: CONVERSACIONES
-- ============================================
CREATE TABLE IF NOT EXISTS CONVERSACIONES (
    id_conversacion  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario       INT UNSIGNED NOT NULL,            -- dueño/cliente
    estado           TINYINT UNSIGNED NOT NULL,        -- FK a ESTADOS_CONVERSACION
    motivo_cierre    TINYINT UNSIGNED NULL,            -- FK a MOTIVOS_CIERRE
    fecha_inicio     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre     DATETIME NULL,
    escalada_a       SMALLINT UNSIGNED NULL,           -- FK a DESTINOS_ESCALADO
    PRIMARY KEY (id_conversacion),
    KEY idx_conv_usuario (id_usuario),
    KEY idx_conv_estado (estado),
    CONSTRAINT fk_conv_usuario
      FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_conv_estado
      FOREIGN KEY (estado) REFERENCES ESTADOS_CONVERSACION(id_estado)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_conv_motivo
      FOREIGN KEY (motivo_cierre) REFERENCES MOTIVOS_CIERRE(id_motivo)
      ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_conv_escalado
      FOREIGN KEY (escalada_a) REFERENCES DESTINOS_ESCALADO(id_destino)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Entidad: MENSAJES  (validación XOR por triggers)
-- ============================================
CREATE TABLE IF NOT EXISTS MENSAJES (
  id_mensaje       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_conversacion  BIGINT UNSIGNED NOT NULL,             -- FK a CONVERSACIONES
  emisor           ENUM('usuario','bot') NOT NULL,       -- quién envió el mensaje
  contenido        TEXT NULL,                            -- puede ser NULL si solo hay adjunto del bot
  id_recurso       BIGINT UNSIGNED NULL,                 -- FK a RECURSOS
  id_faq           BIGINT UNSIGNED NULL,                 -- FK a FAQS
  fecha_envio      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id_mensaje),

  KEY idx_msg_conversacion_fecha (id_conversacion, fecha_envio),
  KEY idx_msg_emisor (emisor),
  KEY idx_msg_recurso (id_recurso),
  KEY idx_msg_faq (id_faq),

  CONSTRAINT fk_msg_conversacion
    FOREIGN KEY (id_conversacion)
    REFERENCES CONVERSACIONES (id_conversacion)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

  CONSTRAINT fk_msg_recurso
    FOREIGN KEY (id_recurso)
    REFERENCES RECURSOS (id_recurso)
    ON UPDATE CASCADE
    ON DELETE SET NULL,

  CONSTRAINT fk_msg_faq
    FOREIGN KEY (id_faq)
    REFERENCES FAQS (id_faq)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER $$

CREATE TRIGGER trg_mensajes_bi
BEFORE INSERT ON MENSAJES
FOR EACH ROW
BEGIN
  -- usuario: no debe traer adjuntos
  IF NEW.emisor = 'usuario' AND (NEW.id_faq IS NOT NULL OR NEW.id_recurso IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un mensaje de usuario no puede tener FAQ ni RECURSO adjuntos';
  END IF;

  -- bot: exactamente uno de los dos adjuntos
  IF NEW.emisor = 'bot' THEN
    IF ((NEW.id_faq IS NOT NULL) + (NEW.id_recurso IS NOT NULL)) <> 1 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un mensaje del bot debe adjuntar exactamente UNA cosa: FAQ o RECURSO';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_mensajes_bu
BEFORE UPDATE ON MENSAJES
FOR EACH ROW
BEGIN
  IF NEW.emisor = 'usuario' AND (NEW.id_faq IS NOT NULL OR NEW.id_recurso IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un mensaje de usuario no puede tener FAQ ni RECURSO adjuntos';
  END IF;

  IF NEW.emisor = 'bot' THEN
    IF ((NEW.id_faq IS NOT NULL) + (NEW.id_recurso IS NOT NULL)) <> 1 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un mensaje del bot debe adjuntar exactamente UNA cosa: FAQ o RECURSO';
    END IF;
  END IF;
END$$

DELIMITER ;

-- ============================================
-- Entidad: TICKETS (escalados a un destino)
-- ============================================
CREATE TABLE IF NOT EXISTS TICKETS (
    id_ticket        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_conversacion  BIGINT UNSIGNED NOT NULL,
    id_usuario       INT UNSIGNED NOT NULL,           -- solicitante/creador
    id_destino       SMALLINT UNSIGNED NOT NULL,      -- a dónde se escaló
    asunto           VARCHAR(160) NOT NULL,
    resumen          TEXT NULL,
    contacto_usuario VARCHAR(190) NULL,               -- email/telefono del usuario
    transcript_texto LONGTEXT NULL,
    estado_envio     ENUM('pendiente','enviado','error') NOT NULL DEFAULT 'pendiente',
    referencia_externa VARCHAR(120) NULL,             -- id externo (ej. nro de ticket)
    fecha_envio      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_ticket),
    KEY idx_tick_conv (id_conversacion),
    KEY idx_tick_usuario (id_usuario),
    KEY idx_tick_destino (id_destino),
    CONSTRAINT fk_tick_conv
      FOREIGN KEY (id_conversacion) REFERENCES CONVERSACIONES(id_conversacion)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tick_usuario
      FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tick_destino
      FOREIGN KEY (id_destino) REFERENCES DESTINOS_ESCALADO(id_destino)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

