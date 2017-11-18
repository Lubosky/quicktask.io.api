require 'rails_helper'

RSpec.describe Api::V1::SignupTokensController, type: :controller do
  describe '#create' do
    it 'returns a 200 upon successful token creation' do
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: 'dev@example.com'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 400 when email is invalid' do
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: 'dev@example'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 400 when email is invalid' do
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: 'devexample.com'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 400 when email is invalid' do
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: '@example.com'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 400 when email is invalid' do
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: 'dev@'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 409 when email is already registered' do
      user = create(:user, email: 'dev@example.dev')
      params = {
        _jsonapi: {
          data: {
            type: 'signup_token',
            attributes: {
              email: 'dev@example.dev'
            }
          }
        }
      }

      post :create, params: params

      expect(response).to have_http_status(:conflict)
    end
  end

  describe '#verify' do
    it 'returns a 200 upon successful token verification' do
      token = signup_token_for(email: 'dev@example.dev')

      get :verify, params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 409 when email is already registered' do
      token = signup_token_for(email: 'dev@example.dev')
      create(:user, email: 'dev@example.dev')

      get :verify, params: { token: token }

      expect(response).to have_http_status(:conflict)
    end

    it 'returns a 401 when token has expired' do
      token = signup_token_for(email: 'dev@example.dev')

      Timecop.freeze(25.hours.from_now) do
        get :verify, params: { token: token }

        expect(response).to have_http_status(:unauthorized)
        expect(response.code).to eq '401'
      end
    end
  end

  def signup_token_for(email:)
    SignupToken.generate_for(email).to_s
  end
end
