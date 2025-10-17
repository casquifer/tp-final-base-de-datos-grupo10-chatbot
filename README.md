# Trabajo Práctico Final - Chatbot - Base de Datos - UNSAM

- Este repositorio está destinado a crear un sistema básico, para poder interactuar con un chatbot, el cúal realizará consultas a una base de datos relacional e intentará contestar con la mejor presición posible.

# Objetivo

- Desarrollar un chatBot capaz de comprender y procesar consultas en lenguaje natural sobre una base de datos estructurada, integrando recursos de soporte y un sistema de tickets.
**Propósito**
- Reducir la cantidad de ticket que se generan al sector de soporte.
**Alcance del Chatbot**
- Responder preguntas frecuentes, buscar y devolver enlaces de tutoriales, proporcionar respuestas directas desde la base de datos y escalar el caso generando un ticket si no encuentra la solución.

# Tecnologías implementadas

- Backend: Laravel
- Base de Datos: MySQL
- Procesamiento de Lenguaje Natural: Ollama
- Frontend: React

# Instalación

- Leer y seguir las instrucciones del archivo "Instalacion.txt"



# Para correr el mambo con Ollama

1. Tuve que tocar el main.py, el .env y el requirements.txt

### Ollama
arrancarlo --> 
sudo docker compose -f docker-compose.ollama.yml up -d

bajarlo --> 
sudo docker compose -f docker-compose.ollama.yml down -v

******
### Back de Py
arrancarlo -->  
sudo docker compose -f docker-compose.backpy.yml up -d

bajarlo --> 
sudo docker compose -f docker-compose.backpy.yml down -v

ejecutar el build segùn Dockerfile
sudo docker compose -f docker-compose.backpy.yml up -d --build

# Info a tener en cuenta

### Si el back no puede mandar bien curls
sudo docker exec -it fastapi-backend bash
apt update && apt install -y curl

### Si bajaste el contenedor o le diste "rm" puede que haya que pullear el modelo de nuevo
sudo docker exec -it ollama bash
ollama pull llama3.2:3b

### Para chequear lo que hay en mysql
sudo docker exec -it mysql bash
mysql -u root -p
santi (password)


