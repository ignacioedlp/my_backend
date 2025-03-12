# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1',
        description: 'Documentación de la API V1'
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      },
      security: [ { bearerAuth: [] } ],
      paths: {},
      servers: [
        {
          url: Rails.env.production? ? 'https://{defaultHost}' : 'http://localhost:3000',
          variables: {
            defaultHost: {
              default: Rails.env.production? ? 'api.myapp.com' : 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  config.openapi_format = :yaml
end
