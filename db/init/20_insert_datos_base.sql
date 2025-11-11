-- 20_insert_datos_base.sql
-- Datos de ejemplo y upserts compatibles con MySQL ≥ 8.0.20
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- USUARIOS
INSERT INTO USUARIOS (id_usuario, nombre, email, password, fecha_alta, activo) VALUES
  (1,'Gonzalo Lopez','gonza@example.com','chat123',NOW(),1),
  (2,'Jonathan Gomez','jony@example.com','chat123',NOW(),1),
  (3,'Santiago Zolla','santi@example.com','chat123',NOW(),1),
  (4,'Nahuel Garcia','nahuel@example.com','chat123',NOW(),1),
  (5,'Rodrigo Casco','casco@example.com','chat123',NOW(),1)
AS new
ON DUPLICATE KEY UPDATE
  nombre = new.nombre,
  password = new.password,
  activo = new.activo;

-- CONVERSACIONES
INSERT INTO CONVERSACIONES (id_conversacion, id_usuario, estado, motivo_cierre, fecha_inicio, fecha_cierre, escalada_a) VALUES
  (1001, 1, 1, NULL, NOW() - INTERVAL 2 DAY, NULL, NULL),
  (1002, 5, 3, NULL, NOW() - INTERVAL 3 DAY, NULL, 1),
  (1003, 3, 2, 1, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY, NULL)
AS new
ON DUPLICATE KEY UPDATE
  id_usuario = new.id_usuario,
  estado = new.estado,
  motivo_cierre = new.motivo_cierre,
  fecha_inicio = new.fecha_inicio,
  fecha_cierre = new.fecha_cierre,
  escalada_a = new.escalada_a;

-- MENSAJES
INSERT INTO MENSAJES (id_mensaje, id_conversacion, emisor, contenido, id_recurso, id_faq, fecha_envio) VALUES
  (1,1001,'usuario','Hola, ¿me ayudan con el alta?', NULL, NULL, NOW() - INTERVAL 2 DAY),
  (2,1001,'bot',NULL, NULL, 1, NOW() - INTERVAL 2 DAY + INTERVAL 5 MINUTE),
  (3,1002,'usuario','No me anda el sistema', NULL, NULL, NOW() - INTERVAL 3 DAY),
  (4,1002,'bot',NULL, 1, NULL, NOW() - INTERVAL 3 DAY + INTERVAL 10 MINUTE)
AS new
ON DUPLICATE KEY UPDATE
  id_conversacion = new.id_conversacion,
  emisor = new.emisor,
  contenido = new.contenido,
  id_recurso = new.id_recurso,
  id_faq = new.id_faq,
  fecha_envio = new.fecha_envio;

-- TICKETS (escalados)
INSERT INTO TICKETS (
  id_ticket, id_conversacion, id_usuario, id_destino, asunto, resumen, contacto_usuario,
  transcript_texto, estado_envio, referencia_externa, fecha_envio
) VALUES
  (9001, 1002, 5, 1, 'Problema de acceso', 'El usuario no puede acceder', 'casco@example.com',
   'Transcript corto...', 'enviado', 'EMAIL-9001', NOW() - INTERVAL 2 DAY + INTERVAL 2 HOUR),
  (9002, 1002, 5, 2, 'Consulta por WhatsApp', 'Conversación escalada a WSP', '+5491100000000',
   'Transcript WSP...', 'enviado', 'WSP-9002', NOW() - INTERVAL 2 DAY + INTERVAL 2 HOUR + INTERVAL 5 MINUTE)
AS new
ON DUPLICATE KEY UPDATE
  id_conversacion = new.id_conversacion,
  id_usuario = new.id_usuario,
  id_destino = new.id_destino,
  asunto = new.asunto,
  resumen = new.resumen,
  contacto_usuario = new.contacto_usuario,
  transcript_texto = new.transcript_texto,
  estado_envio = new.estado_envio,
  referencia_externa = new.referencia_externa,
  fecha_envio = new.fecha_envio;
