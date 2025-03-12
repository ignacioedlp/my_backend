# Imagen base
FROM ruby:3.3.0

# Variables de entorno predeterminadas
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH=/gems

# Instalar dependencias necesarias
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

# Instalar Bundler
RUN gem install bundler:2.5.3

# Crear el directorio de trabajo
WORKDIR /app

# Copiar Gemfile y Gemfile.lock primero para optimizar el cacheo
COPY Gemfile Gemfile.lock ./

# Instalar gemas en función del entorno
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle install --without development test; \
    else \
      bundle install; \
    fi

# Copiar el resto del código de la aplicación
COPY . .

# Copiar y dar permisos al entrypoint
COPY bin/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Precompilar assets en producción
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rake assets:precompile; \
    fi

# Configurar el entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Exponer el puerto de Rails
EXPOSE 3000

# Comando por defecto
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
