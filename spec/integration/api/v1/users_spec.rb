require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }
  let(:token) { user.generate_jwt_token }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/v1/users' do
    get 'Lista de usuarios' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'usuarios listados' do
        run_test!
      end

      response '401', 'no autorizado' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'ID del usuario'

    get 'Obtener detalles de un usuario' do
      tags 'Users'
      security [bearerAuth: []]
      produces 'application/json'

      response '200', 'usuario encontrado' do
        let(:id) { user.id }
        run_test!
      end

      response '404', 'usuario no encontrado' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Actualizar un usuario' do
      tags 'Users'
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: ['email']
      }

      response '200', 'usuario actualizado' do
        let(:id) { user.id }
        let(:user) { { email: 'updated@example.com' } }
        run_test!
      end

      response '422', 'parámetros inválidos' do
        let(:id) { user.id }
        let(:user) { { email: '' } }
        run_test!
      end
    end

    delete 'Eliminar un usuario' do
      tags 'Users'
      security [bearerAuth: []]

      response '200', 'usuario eliminado' do
        let(:id) { user.id }
        run_test!
      end

      response '404', 'usuario no encontrado' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
