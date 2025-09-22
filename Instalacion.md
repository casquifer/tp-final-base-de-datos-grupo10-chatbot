- 1- Clonar Repo e ingresar al directorio creado:
```bash
git clone https://github.com/casquifer/tp-final-base-de-datos-grupo10-chatbot.git
cd tp-final-base-de-datos-grupo10-chatbot
```

- Estructura de carpetas:<br>
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

- 2- Crear branch proyecto-base, hacer checkout a esa rama y pullear:
```bash
git branch proyecto-base
git checkout proyecto-base
git pull origin proyecto-base
```
- 3- Crear Branch dev y hacer checkout a esa rama (vamos a trabajar como siempre partiendo de la rama dev):
```bash
git branch dev
git checkout dev
```

- A partir de acá todos los comandos los vamos a ejecutar en la raíz del proyecto: "/tp-final-base-de-datos-grupo10-chatbot"
- 4- Creamos la red docker "chatnet":
```bash
docker network create chatnet || true
```
- 5- Levantar la Base de Datos
```bash
docker compose -f docker-compose.db.yml up -d
```
- 6- Levantamos el contedor de Ollama y descargamos un modelo
```bash
docker compose -f docker-compose.ollama.yml up -d
docker compose -f docker-compose.ollama.yml exec ollama ollama pull llama3.2:3b
```
- 7- Levantar el LLM service:
```bash
docker compose -f docker-compose.llm.yml up -d --build
```
- 8- Levantar el Backend:
```bash
docker compose -f docker-compose.backend.yml up -d --build
```

- 9- Crear el proyecto de Laravel:
```bash
docker compose -f docker-compose.backend.yml exec php \
  bash -lc 'cd /var/www/app && composer create-project laravel/laravel . && composer require guzzlehttp/guzzle && php artisan key:generate'
```

- 10- Nos damos permisos de edición:
```bash
sudo chown -R $USER:$USER backend frontend llm-service
```

- 11- Reemplazamos el archivo .env que se encuentra en "/backend/app/.env" por el contenido del archivo que está en el directorio raíz llamado ".env_backend" (pero tiene que quedar con el nombre ".env")

- 12- Aplicamos la config del .env y limpiamos cache:
```bash
docker compose -f docker-compose.backend.yml exec php bash -lc '
  cd /var/www/app && \
  php artisan config:clear && \
  php artisan cache:clear file && \
  php artisan route:clear && \
  php artisan view:clear && \
  php artisan config:cache
'
```

-13- Creamos el frontend:
```bash
docker run --rm -v "$PWD/frontend:/app" -w /app node:20-alpine \
  sh -lc 'npm create vite@latest myapp -- --template react && mv myapp/* myapp/.* . 2>/dev/null || true && rmdir myapp'
```

- 14- Instalar dependencias:
```bash
docker run --rm -v "$PWD/frontend:/app" -w /app node:20-alpine \
  sh -lc 'npm install'
```

- 15- Levantamos el servicio de React:
```bash
docker compose -f docker-compose.frontend.yml up -d
docker compose -f docker-compose.frontend.yml logs -f react
```

- 16- Listo! Podemos ver el front en http://localhost:5173/


