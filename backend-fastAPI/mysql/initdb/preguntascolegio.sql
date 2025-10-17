CREATE TABLE IF NOT EXISTS FAQs2 (
    Id_Faq INT AUTO_INCREMENT PRIMARY KEY,
    pregunta VARCHAR(255) NOT NULL,
    palabras_clave VARCHAR(255) NOT NULL,
    respuesta TEXT NOT NULL,
    link_tutorial VARCHAR(255)
);

-- Solo insertar si la tabla está vacía
INSERT INTO FAQs2 (pregunta, palabras_clave, respuesta, link_tutorial)
SELECT * FROM (
    SELECT 
        'No me sirvió la respuesta del bot, ¿cómo creo un ticket?', 
        'ticket; soporte; ayuda; escalar; incidente', 
        'Se procedera a crear un documento con los datos mencionados en el chat y se enviara a soporte, si desea crear un ticket por su cuenta ingrese a ticket.com',
        'https://youtu.be/F-A_ujDnMo4?si=4R_yrVOKiwvpCKSg'
    UNION ALL
    SELECT
        '¿Cómo restablecer la contraseña de un usuario?',
        'restablecer; recuperar; password; clave; olvido',
        'Desde Datos > Usuarios > Editar usuario, elegí ''Restablecer contraseña'' o enviá el enlace de recuperación',
        'https://youtu.be/6VQCn9HwYUw?si=You5cXsfLGl3GZkh'
    UNION ALL
    SELECT
        '¿Cómo activar el doble factor de autenticación (2FA)?',
        'doble factor; 2fa; seguridad; verificación; dos pasos',
        'Ir a Mi Cuenta > Seguridad > Activar Doble Factor y seguir el asistente (guardar códigos de recuperación).',
        'https://youtu.be/lMFdHxyXULM?si=HDZKrx1nm7VUG58Z'
    UNION ALL
    SELECT
        '¿Cómo guardar y restaurar un curso en EVA?',
        'eva; backup; respaldo; restaurar; copia de seguridad',
        'En el curso: Configuración > Copias de seguridad para respaldar. Para restaurar: Administración del curso > Restaurar > subir archivo.',
        'https://youtu.be/ZZAtqW-1158?si=Alhd_MluPQNUD5sC'
    UNION ALL
    SELECT
        '¿Cómo matricular alumnos en un curso EVA?',
        'eva; inscribir; participantes; matricular; alumnos',
        'Curso EVA > Participantes > Matricular usuarios > buscá por nombre o correo > Matricular.',
        'https://youtu.be/cLmiX3O_sYU?si=7E_u6WV3hvbgegYs'
    UNION ALL
    SELECT
        '¿Cómo crear una Noticia en Comunicaciones?',
        'comunicaciones; noticias; publicar; anuncio; novedad',
        'Comunicaciones > Noticias > Crear. Completá título, cuerpo y visibilidad; luego Publicar.',
        'https://youtu.be/Xdl_ZbUZkXc?si=htmY6oUatGW6sQcJ'
    UNION ALL
    SELECT
        '¿Cómo ver quién leyó una Noticia?',
        'reporte; lectura; visto; métricas; comunicaciones',
        'Comunicaciones > Noticias > (Seleccionar) > Reporte de lectura para ver destinatarios y estado.',
        'https://youtu.be/Hpz73Pjf6lI?si=O1zXyo-lQjAjHT9K'
    UNION ALL
    SELECT
        '¿Cómo cambiar el rol de un usuario?',
        'rol; permisos; perfil; docente; familia',
        'Datos > Usuarios > Editar > Rol. Seleccioná el rol correcto y Guardar.',
        'https://youtu.be/R_CrdAWx-vM?si=M-1ATxWfvLvwnWOW'
    UNION ALL
    SELECT
        'Un padre no puede ingresar a la plataforma, ¿qué hago?',
        'credenciales; contraseña; password; no puede entrar; acceso',
        'Ingresá a Datos > Usuarios, buscá al familiar/usuario y seleccioná ''Generar credenciales''.',
        'https://youtu.be/pU89OpwBgOc?si=DTPbIU5Ut8fFRa0o'
    UNION ALL
    SELECT
        'Usuario bloqueado o desactivado, ¿cómo lo habilito?',
        'bloqueado; desactivado; estado; activar; desbloquear',
        'Datos > Usuarios > Editar > Estado: ''Activo''. Si superó intentos, desbloqueá y regenerá credenciales.',
        'https://youtu.be/TUgavfP-br0?si=hQmUTYOLxdt7IN_R'
) AS tmp
WHERE NOT EXISTS (SELECT 15 FROM FAQs);
