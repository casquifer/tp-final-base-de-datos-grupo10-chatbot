# Trabajo Práctico Final - Chatbot - Base de Datos - UNSAM

Este repositorio está destinado a crear un sistema básico, para poder interactuar con un chatbot, el cúal realizará consultas a una base de datos relacional e intentará contestar con la mejor presición posible.<br><br>

#Objetivo

Desarrollar un chatBot capaz de comprender y procesar consultas en lenguaje natural sobre una base de datos estructurada, integrando recursos de soporte y un sistema de tickets.<br>
**Propósito**<br>
Reducir la cantidad de ticket que se generan al sector de soporte.<br>
**Alcance del Chatbot**<br>
Responder preguntas frecuentes, buscar y devolver enlaces de tutoriales, proporcionar respuestas directas desde la base de datos y escalar el caso generando un ticket si no encuentra la solución.<br><br>

#Tecnologías implementadas

Backend: Laravel<br>
Base de Datos: MySQL<br>
Procesamiento de Lenguaje Natural: Ollama<br>
Frontend: React<br><br>

#Instalación

1- Clonar el repo<br><br>
(A partir de acá siempre ejecutamos todo parados en el directorio raíz "tp-final-base-de-datos-grupo10-chatbot")<br>
2- Levantar todo el entorno de desarrollo,  ejecutamos:<br>
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build<br><br>
3- Iniciar Laravel (Backend):<br>
docker compose exec php bash -lc "mkdir -p src && composer create-project laravel/laravel src && cd src && composer require guzzlehttp/guzzle && php artisan key:generate"<br><br>
4- Descargamos el modelo Ollama:<br>
docker compose exec ollama ollama pull llama3.1:8b<br>
(modelo mas liviano) docker compose exec ollama ollama pull llama3.2:3b<br><br>
5- Levantamos el entorno Frontend:<br>
docker run --rm -v "$PWD/frontend:/app" -w /app node:20-alpine \
  sh -lc "npx --yes create-vite@latest . -- --template react && npm install"<br><br>
6- Levantamos React (Frontend):<br>
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d react<br><br>




