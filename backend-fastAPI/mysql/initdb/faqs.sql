CREATE TABLE FAQs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta VARCHAR(255) NOT NULL,
    respuesta TEXT NOT NULL
);

INSERT INTO FAQs (pregunta, respuesta) VALUES
('¿Cuál es el horario de atención?', 'Nuestro horario de atención es de lunes a viernes de 9:00 a 18:00.'),
('¿Cómo puedo restablecer mi contraseña?', 'Podés restablecer tu contraseña desde la página de inicio de sesión haciendo clic en "Olvidé mi contraseña".'),
('¿Dónde están ubicados?', 'Estamos ubicados en Buenos Aires, en Av. Corrientes 1234.'),
('¿Ofrecen envíos a domicilio?', 'Sí, realizamos envíos a todo el país mediante correo y mensajería local.'),
('¿Cómo puedo contactar soporte?', 'Podés escribirnos a soporte@empresa.com o usar el chat en vivo en el sitio web.'),
('¿Tienen atención los fines de semana?', 'Por el momento no atendemos sábados ni domingos.'),
('¿Puedo cambiar un producto?', 'Sí, aceptamos cambios dentro de los 7 días con el ticket de compra.'),
('¿Cuánto tarda un envío?', 'Los envíos dentro de CABA tardan entre 24 y 48 horas.'),
('¿Puedo pagar con tarjeta?', 'Aceptamos tarjetas Visa, Mastercard y MercadoPago.'),
('¿Qué hago si mi pedido llegó incompleto?', 'Contactá a soporte indicando el número de pedido para que podamos resolverlo.');