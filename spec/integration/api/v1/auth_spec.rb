require 'swagger_helper'

RSpec.describe 'API V1 Auth', type: :request do
  path '/api/v1/register' do
    post 'Registro de un nuevo usuario' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: [ 'email', 'password', 'password_confirmation' ]
      }

      response '201', 'usuario registrado correctamente' do
        let(:user) { { email: 'user@example.com', password: 'password123', password_confirmation: 'password123' } }
        run_test!
      end

      response '422', 'parámetros inválidos' do
        let(:user) { { email: 'user@example.com' } }
        run_test!
      end
    end
  end

  path '/api/v1/login' do
    post 'Login de un usuario' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'login exitoso' do
        let(:user) { create(:user, password: 'password123') }
        let(:credentials) { { email: user.email, password: 'password123' } }
        run_test!
      end

      response '401', 'credenciales inválidas' do
        let(:credentials) { { email: 'wrong@example.com', password: 'wrongpass' } }
        run_test!
      end
    end
  end
end
