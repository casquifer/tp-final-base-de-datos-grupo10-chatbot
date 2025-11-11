/*
00_create_catalogos.sql
Crea catálogos sin dependencias.
*/
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: ESTADOS_CONVERSACION
-- ============================================
CREATE TABLE IF NOT EXISTS ESTADOS_CONVERSACION (
    id_estado   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(40) NOT NULL,
    descripcion VARCHAR(200) NULL,
    PRIMARY KEY (id_estado),
    UNIQUE KEY uk_estados_conversacion_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: MOTIVOS_CIERRE
-- ============================================
CREATE TABLE IF NOT EXISTS MOTIVOS_CIERRE (
    id_motivo   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(50)  NOT NULL,
    descripcion VARCHAR(200) NULL,
    PRIMARY KEY (id_motivo),
    UNIQUE KEY uk_motivos_cierre_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: DESTINOS_ESCALADO
-- ============================================
CREATE TABLE IF NOT EXISTS DESTINOS_ESCALADO (
    id_destino  SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(80) NOT NULL,      -- ej: 'email_soporte', 'wsp_soporte'
    tipo        ENUM('email','whatsapp','url','otro') NOT NULL,
    valor       VARCHAR(190) NOT NULL,     -- dirección/canal
    descripcion VARCHAR(200) NULL,
    activo      TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_destino),
    UNIQUE KEY uk_destinos_nombre (nombre),
    KEY idx_destinos_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: RECURSOS
-- ============================================
CREATE TABLE IF NOT EXISTS RECURSOS (
    id_recurso  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo        ENUM('URL','PDF','IMG','MD','TXT') NOT NULL,
    titulo      VARCHAR(160) NOT NULL,
    url         VARCHAR(512) NULL,
    descripcion VARCHAR(255) NULL,
    mime_type   VARCHAR(100) NULL,
    activo      TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_recurso),
    KEY idx_recursos_tipo_activo (tipo, activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: FAQS
-- ============================================
CREATE TABLE IF NOT EXISTS FAQS (
    id_faq     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pregunta   VARCHAR(255) NOT NULL,
    respuesta  TEXT NOT NULL,
    categoria  VARCHAR(80) NULL,
    activa     TINYINT(1) NOT NULL DEFAULT 1,
    fecha_alta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_faq),
    KEY idx_faq_activa (activa),
    KEY idx_faq_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
