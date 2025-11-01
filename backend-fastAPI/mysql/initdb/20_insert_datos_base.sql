-- 20_insert_datos_demo.sql
-- Datos de ejemplo para probar rápidamente el flujo.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- USUARIOS (5 usuarios de demo)
-- ============================================
INSERT INTO USUARIOS (id_usuario, nombre, email, password, fecha_alta, activo) VALUES
    (1, 'Gonzalo Lopez',  'gonza@example.com',   'chat123', NOW(), 1),
    (2, 'Jonathan Gomez', 'jony@example.com',    'chat123', NOW(), 1),
    (3, 'Santiago Zolla', 'santi@example.com',   'chat123', NOW(), 1),
    (4, 'Nahuel Garcia',  'nahuel@example.com',  'chat123', NOW(), 1),
    (5, 'Rodrigo Casco',  'casco@example.com',   'chat123', NOW(), 1)
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre),
    password = VALUES(password),
    activo = VALUES(activo);

-- ============================================
-- DEMO CONVERSACIONES Y MENSAJES (semilla mejorada)
-- Estados: 1=activa, 2=cerrada, 3=escalada
-- Motivos: 1=resuelto_por_bot, 2=resuelto_por_agente, 3=sin_respuesta_usuario, 4=cancelada_usuario, 5=duplicada
-- Destinos: 1=soporte_principal (email), 2=wsp_guardia (whatsapp)
-- ============================================

-- ===== Usuario 1 (GONZALO, id_usuario=1): 3 conversaciones cerradas =====
INSERT INTO CONVERSACIONES (id_conversacion, id_usuario, fecha_inicio, id_estado, fecha_cierre, id_motivo_cierre, escalada, id_destino_escalado, referencia_escalado, titulo)
VALUES
    -- C101: cerrada por bot (2FA)
    (101, 1, NOW() - INTERVAL 7 DAY, 2, NOW() - INTERVAL 6 DAY, 1, 0, NULL, NULL, 'Activación de doble factor'),

    -- C102: cerrada por bot (boletines)
    (102, 1, NOW() - INTERVAL 5 DAY, 2, NOW() - INTERVAL 5 DAY + INTERVAL 30 MINUTE, 1, 0, NULL, NULL, 'Publicación de boletines'),

    -- C103: cerrada sin respuesta (entrevista)
    (103, 1, NOW() - INTERVAL 4 DAY, 2, NOW() - INTERVAL 4 DAY + INTERVAL 2 HOUR, 3, 0, NULL, NULL, 'Solicitud de entrevista con docente')
ON DUPLICATE KEY UPDATE
    id_usuario = VALUES(id_usuario),
    id_estado = VALUES(id_estado),
    fecha_cierre = VALUES(fecha_cierre),
    id_motivo_cierre = VALUES(id_motivo_cierre),
    escalada = VALUES(escalada),
    id_destino_escalado = VALUES(id_destino_escalado),
    referencia_escalado = VALUES(referencia_escalado),
    titulo = VALUES(titulo);

-- MENSAJES de Usuario 1
INSERT INTO MENSAJES (id_mensaje, id_conversacion, emisor, contenido, id_recurso, id_faq, fecha_envio)
VALUES
    -- C101 (2FA)
    (1001, 101, 'usuario', '¿Cómo activo el doble factor de autenticación?', NULL, NULL, NOW() - INTERVAL 7 DAY + INTERVAL 2 MINUTE),
    (1002, 101, 'bot', 'Acá tenés la guía para activar 2FA paso a paso.', 7, NULL, NOW() - INTERVAL 7 DAY + INTERVAL 3 MINUTE),   -- RECURSOS.id=7 Doble factor (manual)
    (1003, 101, 'bot', 'Podés revisar también esta explicación breve.', NULL, 2, NOW() - INTERVAL 7 DAY + INTERVAL 6 MINUTE),       -- FAQS.id=2 (2FA)

    -- C102 (boletines)
    (1004, 102, 'usuario', 'No veo los boletines, ¿cómo se publican?', NULL, NULL, NOW() - INTERVAL 5 DAY + INTERVAL 5 MINUTE),
    (1005, 102, 'bot', 'Antes de publicar, revisá esta configuración.', 20, NULL, NOW() - INTERVAL 5 DAY + INTERVAL 7 MINUTE),       -- RECURSOS.id=20 Configuraciones boletines
    (1006, 102, 'bot', 'Acá está el paso a paso de publicación.', NULL, 14, NOW() - INTERVAL 5 DAY + INTERVAL 10 MINUTE),            -- FAQS.id=14 (boletines)

    -- C103 (entrevista)
    (1007, 103, 'usuario', 'Quiero solicitar una entrevista con el profe de Matemática.', NULL, NULL, NOW() - INTERVAL 4 DAY + INTERVAL 20 MINUTE),
    (1008, 103, 'bot', 'Podés ver cómo se convoca una entrevista desde aquí.', NULL, 21, NOW() - INTERVAL 4 DAY + INTERVAL 22 MINUTE), -- FAQS.id=21 (convocar entrevista)
    (1009, 103, 'bot', 'Si el colegio habilitó horarios, las familias pueden pedirlas desde la app.', NULL, 34, NOW() - INTERVAL 4 DAY + INTERVAL 26 MINUTE) -- FAQS.id=34 (familias solicitan)
ON DUPLICATE KEY UPDATE
    id_conversacion = VALUES(id_conversacion),
    emisor = VALUES(emisor),
    contenido = VALUES(contenido),
    id_recurso = VALUES(id_recurso),
    id_faq = VALUES(id_faq);

-- ===== Usuario 2 (JONATHAN, id_usuario=2): 2 cerradas + 1 activa =====
INSERT INTO CONVERSACIONES (id_conversacion, id_usuario, fecha_inicio, id_estado, fecha_cierre, id_motivo_cierre, escalada, id_destino_escalado, referencia_escalado, titulo)
VALUES
    -- C201: cerrada por agente (escalada)
    (201, 2, NOW() - INTERVAL 3 DAY, 2, NOW() - INTERVAL 2 DAY + INTERVAL 3 HOUR, 2, 1, 1, 'EMAIL-9001', 'Error al cargar notas desde App Docentes'),

    -- C202: cerrada por bot (acceso EVA)
    (202, 2, NOW() - INTERVAL 1 DAY, 2, NOW() - INTERVAL 1 DAY + INTERVAL 25 MINUTE, 1, 0, NULL, NULL, 'Acceso al EVA'),

    -- C203: ACTIVA (autorizar retiro)
    (203, 2, NOW() - INTERVAL 30 MINUTE, 1, NULL, NULL, 0, NULL, NULL, 'Autorizar persona para retiro')
ON DUPLICATE KEY UPDATE
    id_usuario = VALUES(id_usuario),
    id_estado = VALUES(id_estado),
    fecha_cierre = VALUES(fecha_cierre),
    id_motivo_cierre = VALUES(id_motivo_cierre),
    escalada = VALUES(escalada),
    id_destino_escalado = VALUES(id_destino_escalado),
    referencia_escalado = VALUES(referencia_escalado),
    titulo = VALUES(titulo);

-- MENSAJES de Usuario 2
INSERT INTO MENSAJES (id_mensaje, id_conversacion, emisor, contenido, id_recurso, id_faq, fecha_envio)
VALUES
    -- C201 (escalada y luego cerrada por agente)
    (2001, 201, 'usuario', 'Desde la App Docentes no me deja cargar notas, tira error.', NULL, NULL, NOW() - INTERVAL 3 DAY + INTERVAL 10 MINUTE),
    (2002, 201, 'bot', 'Revisá este instructivo de carga de notas en la app.', 59, NULL, NOW() - INTERVAL 3 DAY + INTERVAL 15 MINUTE),  -- RECURSOS.id=59 App Docentes – Carga de notas
    (2003, 201, 'bot', 'Si persiste, escalo a soporte humano.', 44, NULL, NOW() - INTERVAL 3 DAY + INTERVAL 20 MINUTE),                 -- RECURSOS.id=44 Módulo Comunicaciones (ej. referencia general)
    (2004, 201, 'usuario', 'Sigue fallando, por favor escalar.', NULL, NULL, NOW() - INTERVAL 3 DAY + INTERVAL 25 MINUTE),

    -- C202 (acceso EVA)
    (2005, 202, 'usuario', 'No puedo entrar al EVA, ¿cómo se accede?', NULL, NULL, NOW() - INTERVAL 1 DAY + INTERVAL 5 MINUTE),
    (2006, 202, 'bot', 'Te dejo cómo accede un alumno al EVA.', NULL, 62, NOW() - INTERVAL 1 DAY + INTERVAL 7 MINUTE),                  -- FAQS.id=62 (acceso EVA)
    (2007, 202, 'bot', 'También podés revisar esta guía desde la app.', 64, NULL, NOW() - INTERVAL 1 DAY + INTERVAL 10 MINUTE),         -- RECURSOS.id=64 App Familias – Acceso EVA

    -- C203 (ACTIVA: autorizar retiro)
    (2008, 203, 'usuario', 'Quiero autorizar a mi hermano para retirar a mi hijo.', NULL, NULL, NOW() - INTERVAL 25 MINUTE),
    (2009, 203, 'bot', 'Perfecto. Acá está cómo autorizar personas para el retiro.', NULL, 64, NOW() - INTERVAL 23 MINUTE),             -- FAQS.id=64 (autorizar retiro)
    (2010, 203, 'bot', 'Y si usás la app, seguí estos pasos.', 65, NULL, NOW() - INTERVAL 21 MINUTE)                                    -- RECURSOS.id=65 Autorizar personas para retiro
ON DUPLICATE KEY UPDATE
    id_conversacion = VALUES(id_conversacion),
    emisor = VALUES(emisor),
    contenido = VALUES(contenido),
    id_recurso = VALUES(id_recurso),
    id_faq = VALUES(id_faq);

-- ============================================
-- ESCALADOS: snapshot del caso de JONATHAN (C201)
-- ============================================
INSERT INTO ESCALADOS (id_escalado, id_conversacion, id_usuario, id_destino, asunto, resumen, contacto_usuario, transcript_texto, estado_envio, referencia_externa, fecha_creacion, fecha_envio)
VALUES
    (9001, 201, 2, 1,
    'App Docentes: error al cargar notas',
    'Se intentó resolver con instructivo y persistió el error. Se deriva a soporte humano para revisión del caso.',
    'jony@example.com',
    CONCAT(
        'Usuario: Desde la App Docentes no me deja cargar notas, tira error.\n',
        'Bot: Revisá este instructivo de carga de notas en la app.\n',
        'Usuario: Sigue fallando, por favor escalar.'
    ),
    'enviado',
    'EMAIL-9001',
    NOW() - INTERVAL 2 DAY + INTERVAL 2 HOUR,
    NOW() - INTERVAL 2 DAY + INTERVAL 2 HOUR + INTERVAL 5 MINUTE)
ON DUPLICATE KEY UPDATE
    id_conversacion = VALUES(id_conversacion),
    id_usuario = VALUES(id_usuario),
    id_destino = VALUES(id_destino),
    asunto = VALUES(asunto),
    resumen = VALUES(resumen),
    contacto_usuario = VALUES(contacto_usuario),
    transcript_texto = VALUES(transcript_texto),
    estado_envio = VALUES(estado_envio),
    referencia_externa = VALUES(referencia_externa),
    fecha_envio = VALUES(fecha_envio);
