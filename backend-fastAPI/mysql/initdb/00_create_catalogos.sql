/*
00_create_catalogos.sql
ESTADOS_CONVERSACION
MOTIVOS_CIERRE
DESTINOS_ESCALADO
RECURSOS
FAQS
Estos no dependen de nadie. Se dejan con sus PRIMARY KEY y UNIQUE necesarios.
*/

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: ESTADOS_CONVERSACION
-- ============================================
CREATE TABLE IF NOT EXISTS ESTADOS_CONVERSACION (
    id_estado   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(50) NOT NULL,        -- ej: 'activa', 'cerrada', 'escalada'
    descripcion VARCHAR(200) NULL,
    PRIMARY KEY (id_estado),
    UNIQUE KEY uk_estados_conversacion_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: MOTIVOS_CIERRE
-- ============================================
CREATE TABLE IF NOT EXISTS MOTIVOS_CIERRE (
    id_motivo   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(50)  NOT NULL,      -- ej: 'resuelto_por_bot', 'duplicada'
    descripcion VARCHAR(200) NULL,
    PRIMARY KEY (id_motivo),
    UNIQUE KEY uk_motivos_cierre_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: DESTINOS_ESCALADO
-- ============================================
CREATE TABLE IF NOT EXISTS DESTINOS_ESCALADO (
    id_destino  TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(60) NOT NULL,          -- ej: 'soporte_principal', 'wsp_guardia'
    tipo        ENUM('email','whatsapp') NOT NULL,
    valor       VARCHAR(190) NOT NULL,         -- email o número E.164 (ej: +54911XXXXXXX)
    descripcion VARCHAR(200) NULL,
    activo      TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_destino),
    UNIQUE KEY uk_destinos_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: RECURSOS
-- ============================================
CREATE TABLE IF NOT EXISTS RECURSOS (
    id_recurso   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo         ENUM('PDF','VIDEO','URL') NOT NULL,
    titulo       VARCHAR(150) NOT NULL,
    url          VARCHAR(500) NOT NULL,              -- ruta pública o storage interno
    descripcion  VARCHAR(255) NULL,                  -- breve explicación
    mime_type    VARCHAR(100) NULL,                  -- ej: 'application/pdf', 'text/html'
    activo       TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_recurso),
    KEY idx_recursos_tipo_activo (tipo, activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Catálogo: FAQS
-- ============================================
CREATE TABLE IF NOT EXISTS FAQS (
    id_faq       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pregunta     VARCHAR(255) NOT NULL,
    respuesta    TEXT NOT NULL,
    categoria    VARCHAR(80) NULL,               -- ej: 'cuentas', 'pagos', 'envios'
    activa       TINYINT(1) NOT NULL DEFAULT 1,  -- 1=visible/usable
    fecha_alta   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_faq),
    KEY idx_faq_activa (activa),
    KEY idx_faq_categoria (categoria)
    -- Opcional (si querés búsquedas por texto nativas de MySQL 8 InnoDB):
    -- , FULLTEXT KEY ft_faq_busqueda (pregunta, respuesta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
