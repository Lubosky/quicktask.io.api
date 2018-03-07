require 'rails_helper'

RSpec.describe Api::Auth::PasswordController, type: :controller do
  describe '#forgot' do
    it 'returns a 200 when submitted without email' do
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: nil
            }
          }
        }
      }

      post :forgot, params: params

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 200 when user doesn\'t exist' do
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: 'dev@example.dev'
            }
          }
        }
      }

      post :forgot, params: params

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 200 when user does exist' do
      user = create(:user, email: 'dev@example.com')
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: user.email
            }
          }
        }
      }

      post :forgot, params: params

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end
  end

  describe '#verify' do
    it 'returns a 200 when token is valid' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)

      get :verify, params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 401 when token isn\'t valid' do
      get :verify, params: { token: '' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq '401'
    end

    it 'returns a 401 when token isn\'t valid' do
      get :verify, params: { token: 'QWERTY' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq '401'
    end

    it 'returns a 401 when token has expired' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)

      Timecop.freeze(20.minutes.from_now) do
        get :verify, params: { token: token }

        expect(response).to have_http_status(:unauthorized)
        expect(response.code).to eq '401'
      end
    end

    it 'returns a 401 when user password was already updated' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)
      user.update(password: 'abcd1234')

      get :verify, params: { token: token }

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq '401'
    end

    it 'returns a 201 upon successful verification' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)

      get :verify, params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end
  end

  describe '#reset' do
    it 'returns a 200 upon successful password change' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: user.email,
              password: 'password',
              password_confirmation: 'password',
              token: token
            }
          }
        }
      }

      post :reset, params: params

      expect(response).to have_http_status(:ok)
      expect(response.code).to eq '200'
    end

    it 'returns a 401 when token isn\'t valid' do
      user = create(:user, email: 'dev@example.com')
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: user.email,
              password: 'password',
              password_confirmation: 'password',
              token: 'QWERTY'
            }
          }
        }
      }

      post :reset, params: params

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq '401'
    end

    it 'returns a 401 when token has expired' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: user.email,
              password: 'password',
              password_confirmation: 'password',
              token: token
            }
          }
        }
      }

      Timecop.freeze(20.minutes.from_now) do
        post :reset, params: params
      end

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq '401'
    end

    it 'returns a 422 when submitted password_confirmation doesn\'t match password' do
      user = create(:user, email: 'dev@example.com')
      token = password_token_for(user: user)
      params = {
        _jsonapi: {
          data: {
            type: 'password',
            attributes: {
              email: user.email,
              password: 'password',
              password_confirmation: 'p@ssword',
              token: token
            }
          }
        }
      }

      post :reset, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.code).to eq '422'
    end
  end

  def password_token_for(user:)
    PasswordResetToken.generate_for(user).to_s
  end
end
