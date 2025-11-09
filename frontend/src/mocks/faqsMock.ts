import { FAQ } from "./tipos";

export const FAQs: FAQ[] = [
  { id: 1, pregunta: "No me sirvió la respuesta del bot, ¿cómo creo un ticket?", respuesta: "Se procedera a crear un documento con los datos mencionados en el chat y se enviara a soporte, si desea crear un ticket por su cuenta ingrese a ticket.com" },
  { id: 2, pregunta: "¿Cómo restablecer la contraseña de un usuario?", respuesta: "Desde Datos > Usuarios > Editar usuario, elegí 'Restablecer contraseña' o enviá el enlace de recuperación" },
  { id: 3, pregunta: "¿Cómo activar el doble factor de autenticación (2FA)?", respuesta: "Ir a Mi Cuenta > Seguridad > Activar Doble Factor y seguir el asistente (guardar códigos de recuperación)." },
  { id: 4, pregunta: "¿Cómo guardar y restaurar un curso en EVA?", respuesta: "En el curso: Configuración > Copias de seguridad para respaldar. Para restaurar: Administración del curso > Restaurar > subir archivo." },
  { id: 5, pregunta: "¿Cómo matricular alumnos en un curso EVA?", respuesta: "Curso EVA > Participantes > Matricular usuarios > buscá por nombre o correo > Matricular." },
  { id: 6, pregunta: "¿Cómo crear una Noticia en Comunicaciones?", respuesta: "Comunicaciones > Noticias > Crear. Completá título, cuerpo y visibilidad; luego Publicar." },
  { id: 7, pregunta: "¿Cómo ver quién leyó una Noticia?", respuesta: "Comunicaciones > Noticias > (Seleccionar) > Reporte de lectura para ver destinatarios y estado." },
  { id: 8, pregunta: "¿Cómo ver quién leyó una Noticia?", respuesta: "Datos > Usuarios > Editar > Rol. Seleccioná el rol correcto y Guardar." },
  { id: 9, pregunta: "Un padre no puede ingresar a la plataforma, ¿qué hago?", respuesta: "Ingresá a Datos > Usuarios, buscá al familiar/usuario y seleccioná 'Generar credenciales'." },
  { id: 10, pregunta: "Usuario bloqueado o desactivado, ¿cómo lo habilito?", respuesta: "Datos > Usuarios > Editar > Estado: 'Activo'. Si superó intentos, desbloqueá y regenerá credenciales." }
];
