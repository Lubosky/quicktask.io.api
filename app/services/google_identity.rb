require 'google-id-token'
require 'httparty'

class GoogleIdentity
  class_attribute :client_id
  self.client_id = Rails.application.secrets.google_key

  class_attribute :client_secret
  self.client_secret = Rails.application.secrets.google_secret

  class_attribute :token_expiry
  self.token_expiry = 5.minutes

  class_attribute :logger
  self.logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)

  TOKEN_URL = 'https://www.googleapis.com/oauth2/v4/token'.freeze

  def initialize(authorization_code)
    @authorization_code = authorization_code
  end

  def authenticate
    token = retrieve_id_token

    set_extracted_payload(token)
    ensure_proper_audience

    user = fetch_user

    unless user.present?
      user = create_user_from_payload
    end

    user
  end

  def user_identifier
    @payload['sub']
  end

  def name
    @payload['name']
  end

  def first_name
    @payload['given_name']
  end

  def last_name
    @payload['family_name']
  end

  def email_address
    @payload['email']
  end

  def email_verified
    @payload['email_verified']
  end

  def email_verified?
    @payload['email_verified'] == 'true'
  end

  def avatar_url
    @payload['picture']
  end

  def locale
    @payload['locale']
  end

  private

  attr_reader :authorization_code

  def set_extracted_payload(token)
    @payload = GoogleIDToken::Validator.new(expiry: token_expiry).check(token, client_id)
  rescue GoogleIDToken::ValidationError => e
    logger.error "Google token failed to validate (#{e.message})"
    @payload = {}
  end

  def ensure_proper_audience
    unless @payload['aud'].include?(client_id)
      raise "Failed to locate the GOOGLE_KEY #{client_id} in the authorized audience (#{@payload['aud']})"
    end
  end

  def fetch_user
    User.where(google_uid: user_identifier).or(User.where(email: email_address)).first
  end

  def generate_password
    ::PasswordGenerator.generate_password
  end

  def create_user_from_payload
    user_attributes = {
      email: email_address,
      google_uid: user_identifier,
      password: generate_password,
      password_automatically_set: true,
      email_confirmed: email_verified,
      first_name: first_name,
      last_name: last_name
    }

    User.create!(user_attributes)
  end

  def retrieve_id_token
    response = HTTParty.post(TOKEN_URL, token_params)
    unless response.code == 200
      logger.warn "Google API request failed with status #{response.code}."
      logger.debug "Google API request returned error:\n#{response.body}"
      raise StandardError
    end
    response.parsed_response['id_token']
  end

  def token_params
    @token_params ||= {
      body: {
        code: authorization_code,
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: 'postmessage',
        grant_type: 'authorization_code'
      }
    }
  end
end
