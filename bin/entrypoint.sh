#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

echo "Waiting for database..."
until pg_isready -h $DATABASE_HOST -p 5432 -U $DATABASE_USERNAME; do
  sleep 1
done

echo "Running migrations..."
bundle exec rails db:prepare

rm -f /app/tmp/pids/server.pid

echo "Starting Rails application in $RAILS_ENV..."
exec "$@"