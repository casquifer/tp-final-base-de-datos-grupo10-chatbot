CREATE TABLE IF NOT EXISTS FAQs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta VARCHAR(255) NOT NULL,
    respuesta TEXT NOT NULL
);

-- Solo insertar si la tabla está vacía
INSERT INTO FAQs (pregunta, respuesta)
SELECT * FROM (SELECT
  '¿Cuál es el horario de atención?', 'Nuestro horario de atención es de lunes a viernes de 9:00 a 18:00.'
  UNION ALL
  SELECT '¿Cómo puedo restablecer mi contraseña?', 'Podés restablecer tu contraseña desde la página de inicio de sesión haciendo clic en "Olvidé mi contraseña".'
  UNION ALL
  SELECT '¿Dónde están ubicados?', 'Estamos ubicados en Buenos Aires, en Av. Corrientes 1234.'
  UNION ALL
  SELECT '¿Ofrecen envíos a domicilio?', 'Sí, realizamos envíos a todo el país mediante correo y mensajería local.'
  UNION ALL
  SELECT '¿Cómo puedo contactar soporte?', 'Podés escribirnos a soporte@empresa.com o usar el chat en vivo en el sitio web.'
  UNION ALL
  SELECT '¿Tienen atención los fines de semana?', 'Por el momento no atendemos sábados ni domingos.'
  UNION ALL
  SELECT '¿Puedo cambiar un producto?', 'Sí, aceptamos cambios dentro de los 7 días con el ticket de compra.'
  UNION ALL
  SELECT '¿Cuánto tarda un envío?', 'Los envíos dentro de CABA tardan entre 24 y 48 horas.'
  UNION ALL
  SELECT '¿Puedo pagar con tarjeta?', 'Aceptamos tarjetas Visa, Mastercard y MercadoPago.'
  UNION ALL
  SELECT '¿Qué hago si mi pedido llegó incompleto?', 'Contactá a soporte indicando el número de pedido para que podamos resolverlo.'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM FAQs);