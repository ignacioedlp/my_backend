#!/bin/bash
set -e

# Cargar variables de entorno
export $(grep -v '^#' .env | xargs)

# Esperar a que PostgreSQL esté listo
echo "Esperando a que la base de datos esté lista..."
until pg_isready -h $DATABASE_HOST -p 5432 -U $DATABASE_USERNAME; do
  sleep 1
done

# Preparar la base de datos
echo "Preparando la base de datos..."
bundle exec rails db:prepare

# Eliminar el archivo de PID si existe
rm -f /app/tmp/pids/server.pid

# Iniciar el servidor Rails
echo "Iniciando la aplicación Rails..."
exec "$@"
