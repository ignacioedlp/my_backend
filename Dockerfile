FROM ruby:3.3.0

# Instalar dependencias necesarias
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

RUN gem install bundler:2.5.3

# Crear directorio de trabajo
WORKDIR /app

# Copiar Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gemas
RUN bundle install

# Copiar el código de la aplicación
COPY . .

# Copiar el entrypoint y darle permisos de ejecución
COPY bin/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Configurar el entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Exponer el puerto de Rails
EXPOSE 3000

# Comando por defecto
CMD ["rails", "server", "-b", "0.0.0.0"]
