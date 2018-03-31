require 'rails_helper'

RSpec.describe 'POST /api/oauth/google', type: :request do
  let(:code)      { '4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&' }
  let(:id_token)  { 'google_id_token' }
  let(:validator) { mock('GoogleIDToken::Validator') }

  subject { post url_for([:api, :oauth, :google]), params: { code: code } }

  context 'when user doesn\'t exists' do
    before { stub_google_id_token_validator }

    before :each do
      validator.expects(:check)
               .with(id_token, GoogleIdentity.client_id)
               .returns(token_payload)
    end

    it 'connects the Google user identifier to the newly created user' do
      subject

      user = User.find_by(email: token_payload['email'])

      expect(user.google_uid).to eq(token_payload['sub'])
    end

    it 'creates a new user and associates it with Google account' do
      expect { subject }.to change { User.count }.by 1
    end

    it 'returns a 201 upon successful verification' do
      subject

      expect(response).to have_http_status(201)
      expect(response.code).to eq('201')
    end

    it 'returns access token upon successful verification' do
      subject

      expect(JSON.parse(response.body).keys).to contain_exactly('token')
    end
  end

  context 'when user already exists' do
    before { stub_google_id_token_validator }

    before :each do
      create(:user, email: 'frank@catton.com')

      validator.expects(:check)
               .with(id_token, GoogleIdentity.client_id)
               .returns(token_payload)
    end

    it 'doesn\'t create a new user' do
      expect { subject }.not_to change { User.count }
    end

    it 'returns a 201 upon successful verification' do
      subject

      expect(response).to have_http_status(201)
      expect(response.code).to eq('201')
    end

    it 'returns access token upon successful verification' do
      subject

      expect(JSON.parse(response.body).keys).to contain_exactly('token')
    end
  end

  context 'when no authorization code is supplied' do
    it 'returns 401' do
      post url_for([:api, :oauth, :google])

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq('401')
    end
  end

  def stub_google_id_token_validator
    GoogleIDToken::Validator.expects(:new)
                            .with(expiry: GoogleIdentity.token_expiry)
                            .returns(validator)
  end

  def token_payload
    {
      'aud'             => '123456789.apps.googleusercontent.com',
      'email'           => 'frank@catton.com',
      'email_verified'  => 'true',
      'family_name'     => 'Catton',
      'given_name'      => 'Frank',
      'name'            => 'Frank Catton',
      'sub'             => '999000111888'
    }
  end
end
