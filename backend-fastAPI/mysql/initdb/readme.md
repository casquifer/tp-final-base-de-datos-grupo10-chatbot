
# Lo que pueden hacer los usuarios

* **Crear cuenta / iniciar sesión**
  Se registran y quedan guardados en **USUARIOS** (nombre, email, password en texto plano, activo, fecha_alta).
  Podés activar/desactivar usuarios sin borrarlos.

* **Chatear con el bot**
  Cada sesión abre una **CONVERSACIÓN** con estado “activa”, “cerrada” o “escalada”.
  El usuario escribe mensajes (**MENSAJES** con `emisor='usuario'`) y el bot responde (`emisor='bot'`).

* **Ver historial**
  Consultan sus **CONVERSACIONES** y el timeline de **MENSAJES** (orden por fecha, títulos, estado y cierres).

# Lo que hace el bot (IA + base de conocimiento)

* **Respuestas humanizadas**
  El backend (Laravel + Ollama) genera texto y lo guarda en **MENSAJES.contenido**.

* **Citar FAQs estructuradas**
  Si corresponde, la respuesta del bot referencia una **FAQ** (FK `id_faq` → **FAQS**).
  Ventaja: podés editar la FAQ sin alterar los mensajes históricos.

* **Adjuntar recursos reutilizables**
  El bot puede adjuntar un **RECURSO** (PDF/VIDEO/URL) con `id_recurso` → **RECURSOS**.
  Reutilizás manuales/videos/links sin duplicar URL ni descripciones.

* **Reglas anti-errores en la DB**
  En **MENSAJES**:

  * Si `emisor='bot'` → **exactamente uno**: `id_faq XOR id_recurso`.
  * Si `emisor='usuario'` → **sin adjuntos** (ambos NULL).
    El `CHECK` lo garantiza y evita datos inconsistentes.

# Escalado a humano (cuando el bot no resuelve)

* **Marcar conversación “escalada”**
  En **CONVERSACIONES**: `id_estado = escalada`, `escalada=1`, más `id_destino_escalado` (email/WhatsApp) y opcional `referencia_escalado` (ID externo o msg-id de WhatsApp).

* **Crear un “snapshot” en ESCALADOS** (sin ticketera real)
  **ESCALADOS** guarda:

  * FK a **CONVERSACIONES** y **USUARIOS** (quién pide ayuda).
  * FK a **DESTINOS_ESCALADO** (p. ej. `soporte@empresa.com` o `+54911…`).
  * `asunto`, `resumen` (qué se intentó y por qué se deriva).
  * `contacto_usuario` (email/teléfono directo).
  * `transcript_texto` (últimos N mensajes o el chat completo).
  * Flujo de envío: `estado_envio = pendiente/enviado/error`, `fecha_envio` y `referencia_externa` (ID en sistema externo o msg-id de WhatsApp).
    Con esto soporte humano recibe **todo lo necesario** sin integrar una ticketera.

* **Destinos flexibles (email/WhatsApp)**
  Configurables en **DESTINOS_ESCALADO**; cambiás direcciones/números sin redeploy y podés manejar múltiples casillas/canales (guardia, VIP, etc.).

# Gestión de estados y cierre

* **Estados normalizados**
  **ESTADOS_CONVERSACION** evita strings hardcodeados (“activa”, “cerrada”, “escalada”).

* **Motivo de cierre trazable**
  **MOTIVOS_CIERRE** explica por qué se cerró (resuelto por bot, por agente, sin respuesta, cancelada, duplicada).
  Útil para métricas y mejoras del bot.

# Backoffice simple (CRUDs que tu esquema habilita)

* **Usuarios**: alta/baja, activar/desactivar.
* **FAQs**: crear/editar, activar/desactivar, categorías, (opcional) full-text.
* **Recursos**: alta/edición de PDF/VIDEO/URL, descripciones y mime_type, activar/desactivar.
* **Destinos**: emails/números de WhatsApp y estado activo.
* **Conversaciones**: listar por usuario/estado/fecha, ver timeline, cerrar con motivo o marcar escalada.
* **Escalados**: listar por `estado_envio/destino`, ver/reenviar snapshot, setear `enviado` o `error`, guardar `referencia_externa`.

# Experiencia de usuario (front React) que este modelo soporta

* **Login/registro** (según tu requisito, contraseña en claro).
* **Mis Conversaciones**: listado con título, estado, último mensaje, fecha de inicio/cierre.
* **Detalle de conversación** (timeline tipo chat):

  * Mensajes del **usuario**: texto.
  * Mensajes del **bot**:

    * **FAQ adjunta** → tarjeta con pregunta/respuesta + link “ver más”.
    * **Recurso adjunto** → tarjeta con título/URL/descarga o preview.
* **Botón “Escalar a humano”**: crea un **ESCALADO**, marca la **CONVERSACIÓN** como escalada, muestra el destino elegido y (si aplica) la `referencia_externa`.
* **Estado del envío**: el usuario puede ver si el caso está “pendiente”, “enviado” o hubo “error”.

# Integración IA (Ollama) pensada para este esquema

* **Comprensión**: el backend pasa el mensaje + contexto (últimos N **MENSAJES**) al modelo.
* **Búsqueda en conocimiento**:

  1. Intentar mapear a **FAQS** (similaridad/embeddings/reglas).
  2. Si no alcanza, chequear **RECURSOS** (manual/video/status).
  3. Si no resuelve, **escalar** → crear **ESCALADOS** con snapshot y actualizar **CONVERSACIONES**.
* **Trazabilidad total**: al quedar `id_faq/id_recurso` en **MENSAJES** y snapshot en **ESCALADOS**, sabés exactamente qué usó el bot y qué se envió a soporte.

# Métricas y reportes “de fábrica”

* **Eficacia del bot**: % de **CONVERSACIONES** cerradas con `resuelto_por_bot`.
* **Tasa de escalado**: % de conversaciones escaladas.
* **Tiempo a resolución**: `fecha_cierre - fecha_inicio`.
* **Top FAQs** y **Top Recursos**: conteo por `id_faq` / `id_recurso` en **MENSAJES**.
* **Horas pico**: distribución por `fecha_envio`/`fecha_inicio`.
* **Calidad del envío**: ratio `ESCALADOS.enviado` vs `error`, tiempos hasta `fecha_envio`.
* **Efectividad por canal**: performance por **DESTINOS_ESCALADO**.

# Robustez y mantenimiento (sin complicar)

* **3FN simple**: estados/motivos/destinos normalizados, sin duplicar textos.
* **Reglas en la base**: el `CHECK` en **MENSAJES** evita datos inválidos según emisor.
* **Limpieza automática**: `ON DELETE CASCADE` de **MENSAJES** al borrar **CONVERSACIONES**.
* **Histórico estable**: desactivar una FAQ o un Recurso no rompe el historial (los mensajes conservan sus FKs).

# Extensiones fáciles (cuando las necesites)

* **Etiquetas por conversación** (`TAGS` + `CONVERSACION_TAGS`).
* **Adjuntos del usuario** (imágenes/pruebas) con una tabla `ARCHIVOS_MENSAJE` ligada a **MENSAJES**.
* **CSAT** al cierre (campo o tabla de encuesta).
* **Multi-tenant** (agregar `id_tenant` a todas las tablas).
* **Auditoría** (tablas `HISTORIAL_*` o triggers para cambios de estado/escalado).

---

**En resumen:** con este esquema ya podés **registrar usuarios, gestionar conversaciones y mensajes, responder con base de conocimiento (FAQs/Recursos) y derivar a soporte humano con un snapshot en ESCALADOS**. Te deja medir, iterar y mejorar sin meter ticketera real por ahora.