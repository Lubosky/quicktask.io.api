require 'rails_helper'

RSpec.describe Api::V1::StatusController, type: :controller do
  describe '#show' do
    it 'returns a 200' do
      get :show

      expect(response).to have_http_status(204)
    end
  end
end
