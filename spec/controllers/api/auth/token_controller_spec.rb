require 'rails_helper'

RSpec.describe Api::Auth::TokenController, type: :controller do
  describe '#create' do
    it 'returns a 401 when users are not authenticated' do
      create(:user, email: 'dev@example.com', password: 'p@ssword')
      post :create, params: { email: 'wrong@example.com', password: '' }

      expect(response.code).to eq '401'
    end

    it 'returns a 401 when user doesn\'t exist' do
      user = create(:user, email: 'dev@example.com', password: 'p@ssword')

      post :create, params: { email: user.email, password: 'incorrect' }
      expect(response.code).to eq '401'
    end

    it 'returns a 201 upon successful authentication' do
      user = create(:user, email: 'dev@example.com', password: 'p@ssword')

      post :create, params: { email: user.email, password: user.password }
      expect(response.code).to eq '201'
    end
  end
end
