# Base Image
FROM ruby:3.3.0

# Arguments
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH=/gems

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

# Install bundler
RUN gem install bundler:2.5.3

# Working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle install --without development test; \
    else \
      bundle install; \
    fi

# Copy application
COPY . .

# Copy entrypoint
COPY bin/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Precompile assets
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rake assets:precompile; \
    fi

# Set entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Expose port
EXPOSE 3000

# Command
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
