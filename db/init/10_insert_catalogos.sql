/*
10_insert_catalogos.sql
Upserts de catálogos usando alias de fila (AS new) compatible con MySQL ≥ 8.0.20
*/
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ESTADOS_CONVERSACION
INSERT INTO ESTADOS_CONVERSACION (id_estado, nombre, descripcion) VALUES
  (1,'activa','Conversación en curso con el bot/usuario'),
  (2,'cerrada','Cerrada por resolución o por inactividad'),
  (3,'escalada','Escalada a un destino externo (email/wsp)')
AS new  
ON DUPLICATE KEY UPDATE
  nombre = new.nombre,
  descripcion = new.descripcion;

-- MOTIVOS_CIERRE
INSERT INTO MOTIVOS_CIERRE (id_motivo, nombre, descripcion) VALUES
  (1,'resuelto_por_bot','El bot resolvió el caso'),
  (2,'resuelto_por_agente','Resuelto por intervención humana'),
  (3,'duplicada','Conversación duplicada'),
  (4,'abandonada','El usuario abandonó')
AS new
ON DUPLICATE KEY UPDATE
  nombre = new.nombre,
  descripcion = new.descripcion;

-- DESTINOS_ESCALADO
INSERT INTO DESTINOS_ESCALADO (id_destino, nombre, tipo, valor, descripcion, activo) VALUES
  (1,'email_soporte','email','soporte@empresa.com','Buzón oficial de soporte',1),
  (2,'wsp_soporte','whatsapp','+5491100000000','WhatsApp de Soporte',1)
AS new
ON DUPLICATE KEY UPDATE
  tipo = new.tipo,
  valor = new.valor,
  descripcion = new.descripcion,
  activo = new.activo;

-- RECURSOS (ejemplos)
INSERT INTO RECURSOS (id_recurso, tipo, titulo, url, descripcion, activo) VALUES
  (1, 'URL', 'Carta presentación a familias', 'https://docs.google.com/document/d/1gxyhWgTrOWILOBPsgdXetIpJx5oznHOr/edit?usp=sharing&ouid=101412335874528606518&rtpof=true&sd=true', NULL, 1),
    (2, 'URL', 'Guía de acceso (familias)', 'https://docs.google.com/presentation/d/1jfWvjDCpsVQHnA2K9Qp06U-Fqlo_2bXo/edit?usp=sharing&ouid=101412335874528606518&rtpof=true&sd=true', NULL, 1),
    (3, 'URL', 'Guía de acceso (docentes)', 'https://docs.google.com/presentation/d/1pbNYcT6adBFDRuR0wwb5bKx3F5g6Uq8T/edit?usp=sharing&ouid=101412335874528606518&rtpof=true&sd=true', NULL, 1),
    (4, 'URL', 'Educamos Makers. Cómo abrir casos', 'https://drive.google.com/file/d/1cTS-E_s4gl1cQPUTiutRTK6EYL2CHsAR/view?usp=sharing', NULL, 1),
    (5, 'URL', 'Agendar una reunión de asesoría', 'https://calendly.com/educamos/50min', NULL, 1),
    (6, 'URL', 'Módulo Datos', 'https://drive.google.com/file/d/1mbX0aO52Yd0G0V4aHJj_F4BMc5hOgEMx/view?usp=sharing', NULL, 1),
    (7, 'URL', 'Doble factor de autenticación. Manual', 'https://drive.google.com/file/d/1jWItaqWfTIDSLtN-QcmQnVUy420njZ94/view?usp=sharing', NULL, 1),
    (8, 'URL', 'Datos Básicos', 'https://drive.google.com/file/d/1h9R5JTDRbBK_YGnvQqcSIwwZs1oGw_pQ/view?usp=sharing', NULL, 1),
    (9, 'URL', 'Datos/Niveles', 'https://drive.google.com/file/d/1RyZnwQ92QJk38ND9xH7wcOjvA28f52rm/view?usp=sharing', NULL, 1),
    (10, 'URL', 'Datos/Horarios', 'https://drive.google.com/file/d/16QWpsyS60hxva3aRhisox6gUtfWcLx-L/view?usp=sharing', NULL, 1),
    (11, 'URL', 'Configurar feriados y días no lectivos', 'https://docs.google.com/document/d/1vDevwUginjnxSReJQh_zQ_a0Gmmn8hJRbtDHij5zD94/edit?usp=sharing', NULL, 1),
    (12, 'URL', 'Asignar Tutor por división', 'https://docs.google.com/document/d/1ydSqnJ0TVVmrbu0I6c925KJ1JyeXA_50Lh1Mc/edit?usp=sharing', NULL, 1),
    (13, 'URL', 'Login con Google', 'https://drive.google.com/file/d/1-DNmTqMoBZbfumyjH6ucCTPIs13DaYTj/view?usp=sharing', NULL, 1),
    (14, 'URL', 'Campos personalizados', 'https://drive.google.com/file/d/1En2ccvtnilPDMDEBcWiwO9weGuINVnL8/view?usp=sharing', NULL, 1),
    (15, 'URL', 'Creación de filtros', 'https://drive.google.com/file/d/1e6PG0SRUhYxQKoYzkFFuzp0ViKE7xrDC/view?usp=sharing', NULL, 1),
    (16, 'URL', 'Generación de credenciales', 'https://drive.google.com/file/d/1q2h8A6xjY0lLq7dD8bqCvThN4b9eP8Yy/view?usp=sharing', NULL, 1),
    (17, 'URL', 'Generar archivos de credenciales', 'https://drive.google.com/file/d/1mZlA5m8h1z8VbJ7cGQ8WJzL8vJ3eJ2Kx/view?usp=sharing', NULL, 1),
    (18, 'URL', 'Fotografías de alumnos', 'https://drive.google.com/file/d/1lL1oJwJ2bH9yKk0n7C3bM8Z4c9vQ1WwJ/view?usp=sharing', NULL, 1),
    (19, 'URL', 'Módulo Evaluación', 'https://drive.google.com/file/d/1zQ3hQy7k2vHk6b3L9nQ7uE5vH2dR6Y8m/view?usp=sharing', NULL, 1),
    (20, 'URL', 'Configuraciones previas a publicación de boletines', 'https://drive.google.com/file/d/1fW3cE2vJ8lK9mB2nC7xY8pQ4sR5dT6uV/view?usp=sharing', NULL, 1),
    (21, 'URL', 'Mostrar/ocultar calificaciones a padres', 'https://drive.google.com/file/d/1aB2cC3dD4eE5fF6gG7hH8iI9jJ0kK1lM/view?usp=sharing', NULL, 1),
    (22, 'URL', 'Asistencia por materia (cálculo %)', 'https://drive.google.com/file/d/1pO2iI3uU4yY5tT6rR7eE8wW9qQ0aA1bB/view?usp=sharing', NULL, 1),
    (23, 'URL', 'Orden de mérito', 'https://drive.google.com/file/d/1sD2fF3gG4hH5jJ6kK7lL8mM9nN0oO1pQ/view?usp=sharing', NULL, 1),
    (24, 'URL', 'Clima Emocional – configuración', 'https://drive.google.com/file/d/1uI2oO3pP4qQ5rR6sS7tT8uU9vV0wW1xY/view?usp=sharing', NULL, 1),
    (25, 'URL', 'Novedades de OyT (manual + video)', 'https://drive.google.com/file/d/1yU2iI3oO4pP5qQ6rR7sS8tT9uU0vV1wX/view?usp=sharing', NULL, 1),
    (26, 'URL', 'Observaciones en OyT', 'https://drive.google.com/file/d/1kL2jJ3hH4gG5fF6dD7sS8aA9zZ0xX1cC/view?usp=sharing', NULL, 1),
    (27, 'URL', 'Entrevistas: convocatorias', 'https://drive.google.com/file/d/1mN2bB3vV4cC5xX6zZ7aA8sS9dD0fF1gG/view?usp=sharing', NULL, 1),
    (28, 'URL', 'Entrevistas: habilitar horarios docentes', 'https://drive.google.com/file/d/1qW2eE3rR4tT5yY6uU7iI8oO9pP0aA1sS/view?usp=sharing', NULL, 1),
    (29, 'URL', 'Entrevistas: definir horarios disponibles', 'https://drive.google.com/file/d/1tY2uU3iI4oO5pP6aA7sS8dD9fF0gG1hH/view?usp=sharing', NULL, 1),
    (30, 'URL', 'Solicitudes de entrevistas (familias)', 'https://drive.google.com/file/d/1wR2tT3yY4uU5iI6oO7pP8aA9sS0dD1fF/view?usp=sharing', NULL, 1),
    (31, 'URL', 'Nuevas Inscripciones – parámetros', 'https://drive.google.com/file/d/10A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (32, 'URL', 'Reinscripciones – configuración', 'https://drive.google.com/file/d/11A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (33, 'URL', 'Bloqueo temporal para reinscripción', 'https://drive.google.com/file/d/12A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (34, 'URL', 'Guardar y restaurar EVA', 'https://drive.google.com/file/d/13A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (35, 'URL', 'Importación de cursos (EVA)', 'https://drive.google.com/file/d/14A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (36, 'URL', 'Carga de archivos (EVA)', 'https://drive.google.com/file/d/15A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (37, 'URL', 'Ocultar contenidos a alumnos', 'https://drive.google.com/file/d/16A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (38, 'URL', 'Subir y corregir una actividad', 'https://drive.google.com/file/d/17A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (39, 'URL', 'Entrega de tareas por alumno', 'https://drive.google.com/file/d/18A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (40, 'URL', 'Asociar actividades de EVA al Cuaderno', 'https://drive.google.com/file/d/19A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (41, 'URL', 'Creación de grupos (EVA)', 'https://drive.google.com/file/d/1AA2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (42, 'URL', 'Asignar tarea a un grupo', 'https://drive.google.com/file/d/1AB2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (43, 'URL', 'Personalizar pestañas EVA (Moodle 4.5)', 'https://drive.google.com/file/d/1AC2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (44, 'URL', 'Módulo Comunicaciones', 'https://drive.google.com/file/d/1AD2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (45, 'URL', 'Noticias – creación', 'https://drive.google.com/file/d/1AE2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (46, 'URL', 'Circulares – publicación', 'https://drive.google.com/file/d/1AF2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (47, 'URL', 'Informe de lectura', 'https://drive.google.com/file/d/1AG2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (48, 'URL', 'Listas de distribución', 'https://drive.google.com/file/d/1AH2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (49, 'URL', 'Auditoría (Comunicaciones)', 'https://drive.google.com/file/d/1AI2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (50, 'URL', 'Autorizaciones (familias)', 'https://drive.google.com/file/d/1AJ2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (51, 'URL', 'Eventos en App Familias (calendario)', 'https://drive.google.com/file/d/1AK2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P/view?usp=sharing', NULL, 1),
    (52, 'URL', 'Actividades extracurriculares – Parte I', 'https://drive.google.com/file/d/1GLUJBkzQC1mwnvkEQ5c3y0Fb9GqsWCmr/view?usp=sharing', NULL, 1),
    (53, 'URL', 'Actividades extracurriculares – Parte II', 'https://drive.google.com/file/d/1baHd2xvK9nFvhwI6O42wybp6APwxlPVs/view?usp=sharing', NULL, 1),
    (54, 'URL', 'Manual completo de Extracurriculares', 'https://drive.google.com/file/d/1d0i0jwOlY0_eP-i-6E5ZfkZLP91dYh4H/view?usp=sharing', NULL, 1),
    (55, 'URL', 'Módulo Secretaría virtual (presentación)', 'https://docs.google.com/presentation/d/1wCJN3g6xqLZB9d7Xc9X4LwqFQnQeU3n5/edit?usp=sharing&ouid=101412335874528606518&rtpof=true&sd=true', NULL, 1),
    (56, 'URL', 'Biblioteca – Manual', 'https://drive.google.com/file/d/18NppKONXFogkyDCmvBFY1C99Be77Ru-m/view?usp=sharing', NULL, 1),
    (57, 'URL', 'Biblioteca – Cómo cargar ejemplares', 'https://drive.google.com/file/d/1nm-TgZghz--mToa0XN3BtpHxUxR7JJJV/view?usp=sharing', NULL, 1),
    (58, 'URL', 'App Familias – Uso general', 'https://drive.google.com/file/d/1DsuC-xLH12bGGlwD8XpGeU5lDKuy_6aR/view?usp=sharing', NULL, 1),
    (59, 'URL', 'App Docentes – Carga de notas', 'https://drive.google.com/file/d/1cLyrKeYJhNrjwhVZSTIGLEcGQzFtxZA_/view?usp=sharing', NULL, 1),
    (60, 'URL', 'App Docentes – Pasar lista', 'https://drive.google.com/file/d/1ZWvUYbDuyYN7FOI-wpUk8Jlb8NQ7nxjv/view?usp=sharing', NULL, 1),
    (61, 'URL', 'App Docentes – Cargar tareas y exámenes', 'https://drive.google.com/file/d/134HnLPCgi0AWMSr5QFStw8hwII7NGP3e/view?usp=sharing', NULL, 1),
    (62, 'URL', 'App Mensajería – Manual', 'https://drive.google.com/file/d/1m3J_2C2cgzZSrmFqKEQQ-xgnVMahyrlO/view?usp=sharing', NULL, 1),
    (63, 'URL', 'App Familias – Cargar/editar datos personales', 'https://drive.google.com/file/d/1zO4-KxEOxeHhJsBrOzhEV36yqsFHf3__/view?usp=sharing', NULL, 1),
    (64, 'URL', 'App Familias – Acceso EVA (perfil Alumno)', 'https://drive.google.com/file/d/1g3cXPTNuTsoKigIrOL8lu2RSIbN3M8J9/view?usp=sharing', NULL, 1),
    (65, 'URL', 'App Familias – Autorizar personas para retiro', 'https://drive.google.com/file/d/1yYP6DhXk3hJRCLFGMtl2pxBZLxY2Qfgb/view?usp=sharing', NULL, 1)
AS new
ON DUPLICATE KEY UPDATE
  tipo = new.tipo,
  titulo = new.titulo,
  url = new.url,
  descripcion = new.descripcion,
  activo = new.activo;

-- FAQS (ejemplos)
INSERT INTO FAQS (id_faq, pregunta, respuesta, categoria, activa) VALUES
  (1,'¿Qué incluye el Módulo Datos?','Permite configurar datos institucionales, perfiles, niveles, horarios, feriados y credenciales, entre otros ajustes básicos del colegio.','Datos',1),
    (2,'¿Cómo activo el doble factor de autenticación?','Desde el manual de Doble factor: el colegio puede habilitarlo y cada usuario lo configura en su cuenta para sumar seguridad al acceso.','Datos',1),
    (3,'¿Dónde cargo el logo y redes sociales del colegio?','En “Datos Básicos” podés cargar logo, datos institucionales y enlaces a redes sociales.','Datos',1),
    (4,'¿Cómo agrego una división y su tutor?','Usá “Datos/Niveles” para crear la división y asignar tutor; allí también definís rejilla horaria.','Datos',1),
    (5,'¿Cómo configuro rejillas horarias?','Ingresá a “Datos/Horarios” para crear las rejillas que luego usan las divisiones y materias.','Datos',1),
    (6,'¿Cómo defino feriados y días no lectivos?','Desde “Configurar feriados y días no lectivos” marcás fechas que el sistema no tomará como hábiles.','Datos',1),
    (7,'¿Cómo asigno tutor por división?','En “Asignar Tutor por división” elegís la persona responsable del curso: maestro de sala/grado o preceptor.','Datos',1),
    (8,'¿Cómo vinculo cuentas con Google?','En “Login con Google” los usuarios asocian su cuenta de SM Educamos con Google para usar SSO.','Datos',1),
    (9,'¿Para qué sirven los campos personalizados?','Te permiten crear atributos que no existen por defecto en las fichas y decidir dónde se muestran.','Datos',1),
    (10,'¿Cómo creo filtros de usuarios?','Con “Creación de filtros” agrupás usuarios por un criterio para búsquedas y reportes rápidos.','Datos',1),
    (11,'¿Cómo genero o regenero credenciales?','Usá “Generación de credenciales” para emitirlas y “Generar archivos de credenciales” si preferís no enviar correos.','Datos',1),
    (12,'¿Cómo cargo masivamente fotos de alumnos?','En “Fotografías de alumnos” seguí el tamaño permitido y procedimiento de carga masiva.','Datos',1),

    -- ===== 02. EVALUACIÓN =====
    (13,'¿Qué abarca el Módulo Evaluación?','Incluye configuración de boletines, publicación de calificaciones, asistencia por materia e informes como Orden de mérito.','Evaluación',1),
    (14,'¿Cómo configuro la publicación de boletines?','Desde “Configuraciones previas a publicación de boletines” definís visibilidad y parámetros antes de publicar.','Evaluación',1),
    (15,'¿Puedo ocultar calificaciones a padres?','Sí. En “Mostrar/ocultar calificaciones a padres” controlás la visibilidad según la política del colegio.','Evaluación',1),
    (16,'¿Cómo genero el % de asistencia por materia?','Luego de la carga docente, usá la opción dedicada para calcular el porcentaje por materia.','Evaluación',1),
    (17,'¿Cómo saco el informe de Orden de mérito?','Desde Evaluación hay un reporte específico que ordena resultados según los criterios definidos.','Evaluación',1),
    (18,'¿Qué es Clima Emocional?','Una funcionalidad con configuraciones propias para relevar y analizar clima emocional.','Evaluación',1),

    -- ===== 03. ORIENTACIÓN Y TUTORÍA =====
    (19,'¿Qué novedades hay en Orientación y Tutoría?','Hay un manual y un video de nuevas funcionalidades para gestionar observaciones y entrevistas.','Orientación y Tutoría',1),
    (20,'¿Cómo cargo observaciones en OyT?','Desde la pestaña “Observaciones” habilitada por perfil (maestros, profesores, preceptores) según permisos del colegio.','Orientación y Tutoría',1),
    (21,'¿Cómo convoco a una entrevista?','Desde el colegio se crea la entrevista y se convoca a familias o empleados, que pueden aceptarla o rechazarla.','Orientación y Tutoría',1),
    (22,'¿Cómo habilito a docentes para definir horarios de entrevista?','El colegio habilita a los docentes; luego cada docente define sus horarios libres para que las familias pidan entrevistas.','Orientación y Tutoría',1),
    (23,'¿Cómo definen los docentes sus horarios libres?','En la función específica de entrevistas, cada docente carga su disponibilidad y queda visible para familias.','Orientación y Tutoría',1),
    (24,'¿Cómo solicitan entrevistas las familias?','Pueden hacerlo desde la web o la App Familias cuando el colegio habilita horarios disponibles.','Orientación y Tutoría',1),

    -- ===== 04. ADMISIONES Y REINSCRIPCIONES =====
    (25,'¿Cómo parametrizo nuevas inscripciones online?','Usá “Nuevas Inscripciones” para configurar el proceso para aspirantes.','Admisiones y Reinscripciones',1),
    (26,'¿Cómo configuro la re-inscripción de familias?','En “Reinscripciones” definís el proceso para que indiquen continuidad.','Admisiones y Reinscripciones',1),
    (27,'¿Se pueden bloquear usuarios para reinscripción?','Sí, podés bloquear alumnos temporalmente y habilitarlos más tarde en el proceso.','Admisiones y Reinscripciones',1),

    -- ===== 05. EVA =====
    (28,'¿Cómo guardo y restauro EVA?','Existe una opción de “Guardar y restaurar EVA” para respaldos y recuperación.','EVA',1),
    (29,'¿Cómo importo cursos al EVA?','Usá “Importación de cursos” para subir cursos existentes.','EVA',1),
    (30,'¿Cómo cargo archivos en EVA?','Desde “Carga de archivos” incorporás materiales al aula virtual.','EVA',1),
    (31,'¿Puedo ocultar contenidos a alumnos?','Sí, con “Ocultar contenidos a los alumnos” controlás la visibilidad de materiales.','EVA',1),
    (32,'¿Cómo subo y corrijo actividades?','Con “Subir y corregir una actividad” gestionás entregas y correcciones de los alumnos.','EVA',1),
    (33,'¿Cómo entrega una tarea el alumno?','El alumno sube su tarea en EVA y queda disponible para corrección del docente.','EVA',1),
    (34,'¿Cómo asocio actividades del EVA al Cuaderno de profesor?','Desde la función indicada podés asociar actividades y luego importar notas al sistema principal.','EVA',1),
    (35,'¿Cómo creo grupos de trabajo?','Usá “Creación de grupos” para organizar alumnos en grupos.','EVA',1),
    (36,'¿Cómo asigno tareas por grupos?','Con “Asignar tarea a un grupo” dirigís actividades a grupos específicos.','EVA',1),
    (37,'¿Cómo personalizo pestañas en EVA (Moodle 4.5)?','Con “Personalizar pestañas de aulas EVA” ajustás la navegación del aula.','EVA',1),

    -- ===== 06. COMUNICACIONES =====
    (38,'¿Qué incluye el Módulo Comunicaciones?','Noticias, Circulares, Mensajería, Listas de distribución, Autorizaciones, Auditoría y reportes de lectura.','Comunicaciones',1),
    (39,'¿Cómo creo una noticia?','Desde “Noticias” cargás título, contenido e imagen predefinida (logo o genérica).','Comunicaciones',1),
    (40,'¿Cómo creo una circular?','En “Circulares” redactás y publicás el comunicado para los destinatarios definidos.','Comunicaciones',1),
    (41,'¿Puedo ver quién leyó mis envíos?','Sí, el “Informe de lectura” muestra usuarios que leyeron noticias y circulares.','Comunicaciones',1),
    (42,'¿Cómo hago una lista de distribución?','En “Crear listas de distribución” armás destinatarios para usar desde Comunicaciones o correo externo.','Comunicaciones',1),
    (43,'¿Qué es la Auditoría en Comunicaciones?','Permite revisar acciones y cambios para control interno.','Comunicaciones',1),
    (44,'¿Cómo creo autorizaciones para familias?','Usá “Autorizaciones” para que las familias respondan/autoricen actividades y ver reporte de lectura.','Comunicaciones',1),
    (45,'¿Cómo aparecen eventos en la App Familias?','Creando eventos en el calendario del colegio; se muestran en la pestaña HORARIO de la App.','Comunicaciones',1),

    -- ===== 07. EXTRACURRICULARES =====
    (46,'¿Cómo registro actividades extracurriculares?','Seguí la Parte I del manual para registrar actividades.','Extracurriculares',1),
    (47,'¿Cómo gestiono listados, asistencia y evaluación?','Revisá la Parte II para listados, asistencia y evaluación de las actividades.','Extracurriculares',1),
    (48,'¿Hay un manual completo de Extracurriculares?','Sí, podés consultar el manual completo del módulo.','Extracurriculares',1),

    -- ===== 08. SECRETARÍA VIRTUAL =====
    (49,'¿Qué trámites puedo generar en Secretaría virtual?','Dos tipos: Trámites informativos y Envío de documentación (que puede adjuntarse en la ficha del alumno).','Secretaría Virtual',1),
    (50,'¿Para qué sirven los Trámites informativos?','Para enviar información y documentación solicitando confirmación de lectura.','Secretaría Virtual',1),
    (51,'¿Cómo funciona el Envío de documentación?','Solicitás documentación a familias y podés adjuntarla automáticamente a la ficha del alumno.','Secretaría Virtual',1),

    -- ===== 09. BIBLIOTECA =====
    (52,'¿Hay manual de Biblioteca?','Sí, hay un manual del módulo Biblioteca con instrucciones generales.','Biblioteca',1),
    (53,'¿Cómo cargo ejemplares en Biblioteca?','Usá “Cómo cargar ejemplares” para ingresar libros y material.','Biblioteca',1),
    (54,'¿Se puede importar el catálogo de Biblioteca?','Sí, existe importación de catálogo para evitar carga uno a uno.','Biblioteca',1),

    -- ===== 10. APPS =====
    (55,'¿Qué es la App SM Educamos Familias?','Una app iOS/Android para familias (v.1.58.0 al 20/08/2025) que muestra información según permisos del colegio.','Apps',1),
    (56,'¿Qué funciones tiene la App Docentes?','App iOS/Android (v.1.29.0 al 20/08/2025) para registrar notas, pasar lista y crear tareas/exámenes.','Apps',1),
    (57,'¿Qué funciones tiene la App Mensajería?','App Android/iOS (v.1.19.0/1.18.0) vinculada con Apps Familias/Docentes para mensajería.','Apps',1),
    (58,'¿Puedo cargar notas desde la App Docentes?','Sí, sobre ítems del Cuaderno de profesor creados en la web.','Apps',1),
    (59,'¿Se puede pasar lista desde la App Docentes?','Sí, por materia (no por día).','Apps',1),
    (60,'¿Se pueden crear tareas y exámenes desde la App Docentes?','Sí, para todo el curso o personalizado por alumno; quedan visibles en web y app.','Apps',1),

    -- ===== 11. PADRES Y ALUMNOS =====
    (61,'¿Cómo cargan padres/tutores sus datos y los de sus hijos?','Desde la web pueden editar datos personales y personas autorizadas para retiro (las fotos se cargan masivamente desde el colegio).','Padres y Alumnos',1),
    (62,'¿Cómo accede un alumno al EVA?','El acceso al EVA es con las credenciales del alumno; si un padre quiere ver las aulas debe usar la cuenta del alumno.','Padres y Alumnos',1),
    (63,'¿Cómo reciben/solicitan entrevistas las familias?','Pueden recibir convocatorias, aceptarlas o rechazarlas y solicitar entrevistas desde web o app.','Padres y Alumnos',1),
    (64,'¿Cómo autorizo personas para retiro de estudiantes?','Desde la App Familias el perfil Padre/Tutor puede cargar personas autorizadas para el retiro.','Padres y Alumnos',1),

    -- ===== Novedades (ejemplos resumidos) =====
    (65,'¿Qué novedades hay sobre EVA para docentes?','Hay un informe de uso por docente (accesos, sesiones, etc.) disponible desde la administración del EVA.','Novedades',1),
    (66,'¿Qué cambió en el pie de página y enlaces?','Se actualiza con datos de contacto y se agrega una sección de Enlaces personalizable visible en web y apps.','Novedades',1),
    (67,'¿Puedo leer PDFs sin descarga en Mensajería?','Sí, el lector PDF integrado permite visualizar documentos directamente.','Novedades',1),
    (68,'¿Las notificaciones push en App Docentes son configurables?','Sí, se pueden configurar por funcionalidad, similar a la App Familias.','Novedades',1),
    (69,'¿Hay nuevas imágenes para Noticias?','Sí, al crear una noticia podés elegir imagen de logo del colegio o una genérica predefinida.','Novedades',1),
    (70,'¿Se pueden importar notas mediante Excel?','Sí, en Evaluación/Carga de notas ahora es posible importar desde un archivo Excel.','Novedades',1)
AS new
ON DUPLICATE KEY UPDATE
  pregunta = new.pregunta,
  respuesta = new.respuesta,
  categoria = new.categoria,
  activa = new.activa;













