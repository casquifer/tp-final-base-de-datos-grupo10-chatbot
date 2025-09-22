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

Estructura de carpetas:<br><br>

tp-final-base-de-datos-grupo10-chatbot/<br>
├─ .env<br>
├─ docker-compose.db.yml<br>
├─ docker-compose.backend.yml<br>
├─ docker-compose.frontend.yml<br>
├─ docker-compose.ollama.yml<br>
├─ docker-compose.llm.yml<br>
├─ backend/<br>
│  ├─ app/                # <- acá se creará Laravel (vacío ahora)<br>
│  ├─ docker/<br>
│  │  └─ Dockerfile<br>
│  └─ nginx/<br>
│     └─ default.conf<br>
├─ frontend/              # <- acá se creará React (vacío ahora)<br>
└─ llm-service/<br>
   ├─ Dockerfile<br>
   ├─ requirements.txt<br>
   └─ main.py<br>

<br>

1- Clonar el repo, crear rama dev, hacer checkout a dev y empezar la instalación.<br><br>
(A partir de acá siempre ejecutamos todo parados en el directorio raíz "tp-final-base-de-datos-grupo10-chatbot")<br>

2- Crear la red docker entre los contenedores:<br>
docker network create chatnet || true<br>

3- Levantar la Base de Datos<br>
docker compose -f docker-compose.db.yml up -d<br><br>

4- Levantamos el contedor de Ollama y descargamos un modelo<br>
docker compose -f docker-compose.ollama.yml up -d<br>
docker compose -f docker-compose.ollama.yml exec ollama ollama pull llama3.2:3b<br><br>

5- Levantar el LLM service:<br>
docker compose -f docker-compose.llm.yml up -d --build<br><br>

6- Levantar el Backend:<br>
docker compose -f docker-compose.backend.yml up -d --build
<br><br>

7- Crear el proyecto de Laravel:<br>
docker compose -f docker-compose.backend.yml exec php \
  bash -lc 'cd /var/www/app && composer create-project laravel/laravel . && composer require guzzlehttp/guzzle && php artisan key:generate'<br><br>

8- Nos damos permisos de edición:<br>
sudo chown -R $USER:$USER backend frontend llm-service<br><br>

9- Reemplazamos el archivo .env que se encuentra en /backend/app/.env por el archivo que está en el directorio raíz llamado .env_backend<br><br>

10- Aplicamos la config del .env y limpiamos cache:<br>
docker compose -f docker-compose.backend.yml exec php bash -lc '
  cd /var/www/app && \
  php artisan config:clear && \
  php artisan cache:clear file && \
  php artisan route:clear && \
  php artisan view:clear && \
  php artisan config:cache
'
<br><br>

11- Dentro de la ruta /backend/app/routes, crear el archivo "api.php":<br>
<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ChatController;

Route::post('/chat', [ChatController::class, 'ask']);
<br><br>

12- Crear el controlador del chat en app/Http/Controllers/ChatController.php:
<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class ChatController extends Controller
{
    public function ask(Request $request)
    {
        $question = $request->input('message');
        if (!$question) return response()->json(['error'=>'message is required'],422);

        $resp = Http::timeout(60)->post('http://llm-service:8000/nl2sql', ['question'=>$question]);
        if (!$resp->ok()) return response()->json(['error'=>'LLM unavailable','detail'=>$resp->body()],500);

        $sql = trim($resp->json('sql',''));
        if (!preg_match('/^\s*select\s/i',$sql)) return response()->json(['error'=>'Only SELECT allowed','sql'=>$sql],400);
        if (!preg_match('/\blimit\s+\d+/i',$sql)) $sql .= " LIMIT 100";

        try { $rows = DB::select($sql); }
        catch (\Throwable $e) {
            return response()->json(['error'=>'SQL execution failed','sql'=>$sql,'detail'=>$e->getMessage()],400);
        }

        return response()->json(['answer'=>'OK','usedSQL'=>$sql,'rows'=>$rows]);
    }
}

13- En la raíz del proyecto aplicamos:
docker compose -f docker-compose.backend.yml exec php bash -lc 'cd /var/www/app && php artisan config:clear'


14- Creamos el frontend:
docker run --rm -v "$PWD/frontend:/app" -w /app node:20-alpine \
  sh -lc 'npm create vite@latest myapp -- --template react && mv myapp/* myapp/.* . 2>/dev/null || true && rmdir myapp'

15- Instalar dependencias:
docker run --rm -v "$PWD/frontend:/app" -w /app node:20-alpine \
  sh -lc 'npm install'










