#!/bin/bash
set -e

# Cargar variables de entorno
export $(grep -v '^#' .env | xargs)

# Esperar a que PostgreSQL esté listo
echo "Esperando a que la base de datos esté lista..."
until pg_isready -h $DATABASE_HOST -p 5432 -U $DATABASE_USERNAME; do
  sleep 1
done

# Ejecutar migraciones en cualquier entorno
echo "Ejecutando migraciones..."
bundle exec rails db:migrate

# Eliminar el archivo de PID si existe
rm -f /app/tmp/pids/server.pid

# Iniciar la aplicación
echo "Iniciando la aplicación Rails en $RAILS_ENV..."
exec "$@"