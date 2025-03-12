¡Vamos a ello! 🚀 Te voy a crear un README.md profesional, detallado y bien estructurado, ideal para que cualquier desarrollador pueda entender y levantar tu proyecto sin problemas.

Este README incluirá información sobre la configuración, ejecución, autenticación, uso de la API, y la estructura del proyecto Docker.

📚 My Rails API Project

Backend en Ruby on Rails 7.0.0 con autenticación JWT, panel de administración con ActiveAdmin, Redis para cacheo, y todo dockerizado con PostgreSQL y Redis. 🚀

🚀 Características Principales

🔐 Autenticación segura con Devise + JWT.

🧑‍💼 Panel Administrativo con ActiveAdmin para gestionar recursos de forma intuitiva.

⚡ API RESTful para interacción con clientes externos.

🐳 Dockerizado: PostgreSQL y Redis como servicios en contenedores.

🏷️ Gestión de Roles de usuario usando Rolify y Pundit.

🔄 Redis para manejo de caché y mejoras de rendimiento.

📂 Estructura del Proyecto

├── app/                     # Código de la aplicación Rails
├── bin/                     # Scripts ejecutables (incluye entrypoint.sh)
├── config/                  # Configuración de Rails
├── db/                      # Migraciones y Seeds
├── Dockerfile               # Dockerfile principal
├── docker-compose.yml       # Orquestación de Docker
├── .env                     # Variables de entorno
├── Gemfile                  # Dependencias Ruby
├── README.md                # Documentación del proyecto

⚙️ Requisitos Previos

Docker

Docker Compose

Ruby 3.0.0 (para desarrollo local fuera de Docker)

⚡ Configuración Inicial

✅ 1. Clonar el Proyecto

git clone https://github.com/tu-usuario/my-rails-api.git
cd my-rails-api

✅ 2. Configurar Variables de Entorno

Crea un archivo .env en la raíz del proyecto con la siguiente configuración:

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_secure_password
DATABASE_HOST=db

# Redis
REDIS_URL=redis://redis:6379/0

# Devise JWT
DEVISE_JWT_SECRET_KEY=your_super_secret_jwt_key

# Rails
RAILS_ENV=development

⚠️ Importante: Este archivo ya está en .gitignore, ¡no lo subas al repositorio!

✅ 3. Construir y Levantar Contenedores

docker-compose build --no-cache
docker-compose up

El entrypoint.sh se encargará de esperar a la base de datos y ejecutar db:prepare automáticamente.

✅ 4. Crear AdminUser para ActiveAdmin

Accede a la consola de Rails y crea un usuario administrador:

docker-compose exec web rails console

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

🛠️ Comandos Útiles

Levantar el entorno Docker

docker-compose up

Reconstruir el entorno completamente

docker-compose down --volumes --remove-orphans
docker-compose build --no-cache
docker-compose up

Acceder al contenedor web

docker-compose exec web bash

Ver logs de Redis o PostgreSQL

docker-compose logs redis
docker-compose logs db

🔐 Autenticación con JWT

🚀 1. Registro de Usuario

POST /api/v1/users

{
  "user": {
    "email": "user@example.com",
    "password": "password",
    "password_confirmation": "password"
  }
}

🚀 2. Inicio de Sesión

POST /api/v1/users/sign_in

{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}

✅ La respuesta incluirá el token JWT en el header Authorization.

🚀 3. Cerrar Sesión

DELETE /api/v1/users/sign_out

⚡ Usar el Token JWT

Para acceder a endpoints protegidos, añade este encabezado:

Authorization: Bearer <your-jwt-token>

📚 Endpoints Principales

Método

Ruta

Descripción

Autenticación

POST

/api/v1/users

Registrar nuevo usuario

❌ No

POST

/api/v1/users/sign_in

Iniciar sesión (obtener JWT)

❌ No

DELETE

/api/v1/users/sign_out

Cerrar sesión

✅ Sí

GET

/api/v1/posts

Listar posts

✅ Sí

POST

/api/v1/posts

Crear nuevo post

✅ Sí

PUT

/api/v1/posts/:id

Actualizar post

✅ Sí

DELETE

/api/v1/posts/:id

Eliminar post

✅ Sí

🧑‍💼 Acceso a ActiveAdmin

URL: http://localhost:3000/admin

Iniciar sesión con las credenciales del AdminUser creado previamente.

🔄 Redis y Caché

Redis ya está configurado en el entorno. Puedes interactuar con él:

docker-compose exec redis redis-cli

Comprobar si Redis está corriendo:

docker-compose exec redis redis-cli ping

Deberías recibir: PONG

🚀 Despliegue en Producción

Configura las variables de entorno en tu entorno de producción.

Ejecuta las migraciones:

docker-compose run web rails db:migrate RAILS_ENV=production

Levanta los contenedores:

docker-compose -f docker-compose.prod.yml up -d

⚠️ Asegúrate de tener configurado un docker-compose.prod.yml con tus configuraciones de producción!

🐛 Solución de Problemas

pg_isready: command not found✅ Ya está solucionado en el Dockerfile añadiendo postgresql-client.

NoMethodError: undefined method 'current=' for class Redis✅ Solucionado usando ConnectionPool para gestionar Redis.

Errores de Autenticación en PostgreSQL✅ Verifica que las variables POSTGRES_USER y POSTGRES_PASSWORD estén correctamente definidas en .env.

🧹 Comandos para Limpiar Docker

Eliminar contenedores, volúmenes y redes

docker system prune -af --volumes

Eliminar solo volúmenes

docker volume prune -f

❤️ Contribuciones

¡Las contribuciones son bienvenidas! Si deseas aportar, abre un PR o crea un issue.

📝 Licencia

Este proyecto está bajo la MIT License.


TODO:
1. Standard code gem
2. Commits
3. Veremos