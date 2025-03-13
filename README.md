# My Backend Boilerplate

## Overview
This is a backend boilerplate project designed to kickstart your development process. It includes essential configurations and best practices for building scalable and maintainable backend applications.

## Features
- Pre-configured environment setup
- Docker support for containerized development
- Rubocop integration for code style enforcement
- Example environment variables
- ActiveAdmin for admin interface
- REST API for user management
- Redis for caching and performance improvements
- JWT authentication with Devise

## Dependencies

### Main Gems
- [Rails](https://rubyonrails.org/) - Web framework
- [Rubocop](https://github.com/rubocop/rubocop) - Code linter

### Database
- [PostgreSQL](https://www.postgresql.org/) - Database system

### Testing
- [RSpec](https://rspec.info/) - Testing framework

### Authentication & Authorization
- [Devise](https://github.com/heartcombo/devise) - Authentication solution
- [Pundit](https://github.com/varvet/pundit) - Authorization system
- [Rolify](https://github.com/RolifyCommunity/rolify) - Role management

### OAuth
- [OmniAuth](https://github.com/omniauth/omniauth) - OAuth2 framework
- [OmniAuth Google](https://github.com/zquestz/omniauth-google-oauth2) - Google OAuth2 strategy

### Admin Interface
- [ActiveAdmin](https://activeadmin.info/) - Administration framework

### API
- [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers) - JSON serialization

### Other
- [Dotenv](https://github.com/bkeepers/dotenv) - Environment variables management

## Getting Started

### Prerequisites
- Ruby (version specified in .ruby-version)
- Docker (optional)

### Installation
1. Clone the repository
2. Run `bundle install` to install dependencies
3. Copy `.env.example` to `.env` and configure your environment variables

### Running the Application
```bash
rails server
```

### Docker Usage
```bash
docker-compose up
```

## Environment Variables
See `.env.example` for required environment variables.

## Code Style
This project uses Rubocop for maintaining code quality. Configuration can be found in `.rubocop.yml`.

## Redis Configuration
```bash
docker-compose exec redis redis-cli
```

## API Documentation
### Authentication
```http
POST /api/v1/users/sign_in
```

### User Management
```http
GET /api/v1/users
```

## Production Deployment
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Testing
```bash
docker compose exec web bundle exec rspec spec/controllers --format documentation
```

## Create swagger
```bash
docker compose exec web bundle exec rake rswag:specs:swaggerize
```

## Contributing
Pull requests are welcome. Please follow the existing code style and add tests for new features.