/*
01_create_entidades.sql
USUARIOS
CONVERSACIONES (FK a: USUARIOS, ESTADOS_CONVERSACION, MOTIVOS_CIERRE, DESTINOS_ESCALADO)
MENSAJES (FK a: CONVERSACIONES, RECURSOS, FAQS + el CHECK XOR)
TICKETS (FK a: CONVERSACIONES, USUARIOS, DESTINOS_ESCALADO)
*/

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- Entidad: USUARIOS
-- ============================================
CREATE TABLE IF NOT EXISTS USUARIOS (
    id_usuario  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(120) NOT NULL,
    email       VARCHAR(190) NOT NULL,           -- 190 evita problemas con índices en utf8mb4
    password    VARCHAR(100) NOT NULL,           -- TEXTO PLANO (según requisito)
    fecha_alta  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo      TINYINT(1) NOT NULL DEFAULT 1,   -- 1=activo, 0=inactivo
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uk_usuarios_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Entidad: CONVERSACIONES
-- Depende de: USUARIOS, ESTADOS_CONVERSACION, MOTIVOS_CIERRE, DESTINOS_ESCALADO
-- ============================================
CREATE TABLE IF NOT EXISTS CONVERSACIONES (
    id_conversacion      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario           INT UNSIGNED    NOT NULL,          -- FK a USUARIOS
    fecha_inicio         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_estado            TINYINT UNSIGNED NOT NULL,         -- FK a ESTADOS_CONVERSACION
    fecha_cierre         DATETIME        NULL,              -- null mientras esté activa/escalada
    id_motivo_cierre     TINYINT UNSIGNED NULL,             -- FK a MOTIVOS_CIERRE (opcional)
    escalada             TINYINT(1)      NOT NULL DEFAULT 0, -- 1 si se escaló a humano
    id_destino_escalado  TINYINT UNSIGNED NULL,             -- FK a DESTINOS_ESCALADO (opcional)
    referencia_escalado  VARCHAR(120)    NULL,              -- id de ticket externo / msg id wsp
    titulo               VARCHAR(120)    NULL,              -- etiqueta corta opcional

    PRIMARY KEY (id_conversacion),

    KEY idx_conv_usuario_fecha (id_usuario, fecha_inicio),
    KEY idx_conv_estado        (id_estado),
    KEY idx_conv_motivo        (id_motivo_cierre),
    KEY idx_conv_destino       (id_destino_escalado),

    CONSTRAINT fk_conv_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIOS (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_conv_estado
        FOREIGN KEY (id_estado)
        REFERENCES ESTADOS_CONVERSACION (id_estado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_conv_motivo
        FOREIGN KEY (id_motivo_cierre)
        REFERENCES MOTIVOS_CIERRE (id_motivo)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_conv_destino
        FOREIGN KEY (id_destino_escalado)
        REFERENCES DESTINOS_ESCALADO (id_destino)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    -- ============================================
-- Entidad: ESCALADOS
-- Propósito: casos derivados a soporte (email/WhatsApp/etc.)
-- Guarda snapshot de la conversación + datos para envío/seguimiento.
-- Depende de: CONVERSACIONES, USUARIOS, DESTINOS_ESCALADO
-- ============================================
CREATE TABLE IF NOT EXISTS ESCALADOS (
    id_escalado        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_conversacion    BIGINT UNSIGNED NOT NULL,            -- FK a CONVERSACIONES
    id_usuario         INT UNSIGNED NOT NULL,               -- FK a USUARIOS (quién pidió ayuda)
    id_destino         TINYINT UNSIGNED NOT NULL,           -- FK a DESTINOS_ESCALADO (a dónde se envía)
    asunto             VARCHAR(150) NOT NULL,               -- título/resumen corto
    resumen            TEXT NOT NULL,                       -- qué se intentó / por qué se deriva
    contacto_usuario   VARCHAR(190) NULL,                   -- email/teléfono si querés pasarlo explícito
    transcript_texto   MEDIUMTEXT NULL,                     -- transcripción textual (chat completo o últimos N)
    estado_envio       ENUM('pendiente','enviado','error') NOT NULL DEFAULT 'pendiente',
    referencia_externa VARCHAR(120) NULL,                   -- id en sistema externo / id de msg WSP (opcional)
    fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_envio        DATETIME NULL,                       -- cuándo se envió/atendió externamente

    PRIMARY KEY (id_escalado),

    KEY idx_esc_conversacion (id_conversacion),
    KEY idx_esc_usuario (id_usuario),
    KEY idx_esc_destino (id_destino),
    KEY idx_esc_estado_envio (estado_envio),

    CONSTRAINT fk_esc_conversacion
        FOREIGN KEY (id_conversacion)
        REFERENCES CONVERSACIONES (id_conversacion)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_esc_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIOS (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_esc_destino
        FOREIGN KEY (id_destino)
        REFERENCES DESTINOS_ESCALADO (id_destino)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
