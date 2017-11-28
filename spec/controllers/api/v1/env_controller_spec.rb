require 'rails_helper'

RSpec.describe Api::V1::EnvController, type: :controller do
  describe '#show' do
    it 'returns a 200' do
      get :show

      expect(response).to have_http_status(:success)
    end
  end
end
