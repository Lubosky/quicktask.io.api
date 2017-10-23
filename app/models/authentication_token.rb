class AuthenticationToken
  attr_reader :token
  attr_reader :payload

  class_attribute :token_expiry_time
  self.token_expiry_time = 12.hours

  class_attribute :token_audience_identifier
  self.token_audience_identifier = -> { Rails.application.secrets.application_key }

  class_attribute :token_issuer_identifier
  self.token_issuer_identifier = -> { Rails.application.secrets.application_domain }

  class_attribute :token_secret_signature_key
  self.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }

  TOKEN_SIGNATURE_ALGORITHM = 'HS256'.freeze

  def initialize(payload: {}, token: nil, verify_options: {})
    if token.present?
      @payload, _ = JWT.decode(token.to_s, decode_key, true, options.merge(verify_options))
      @token = token
    else
      @payload = claims.merge(payload)
      @token = JWT.encode(@payload, secret_key, TOKEN_SIGNATURE_ALGORITHM)
    end
  end

  def entity_for(entity_class)
    entity = entity_class.find @payload['sub']
    return entity unless token_revoked?(entity)
  end

  def revoke_for(entity_class)
    entity = entity_class.find_by(subject_id: @payload['sub'], id: @payload['jti'])
    entity.present? && entity.try(:destroy)
  end

  def to_json(_options = {})
    { token: @token }.to_json
  end

  private

  def secret_key
    token_secret_signature_key.call
  end

  def decode_key
    secret_key
  end

  def token_revoked?(entity)
    return true unless entity
    !entity.tokens.find(@payload['jti'])
  end

  def options
    verify_claims.merge(algorithm: TOKEN_SIGNATURE_ALGORITHM)
  end

  def claims
    _claims = {}
    _claims[:aud] = token_audience if verify_audience?
    _claims[:exp] = token_lifetime if verify_lifetime?
    _claims[:iss] = token_issuer if verify_issuer?
    _claims
  end

  def verify_claims
    {
      aud: token_audience,
      iss: token_issuer,
      verify_aud: verify_audience?,
      verify_expiration: verify_lifetime?,
      verify_iss: verify_issuer?
    }
  end

  def token_audience
    verify_audience? && token_audience_identifier.call
  end

  def verify_audience?
    token_audience_identifier.present?
  end

  def token_issuer
    verify_issuer? && token_issuer_identifier.call
  end

  def verify_issuer?
    token_issuer_identifier.present?
  end

  def token_lifetime
    token_expiry_time.from_now.to_i if verify_lifetime?
  end

  def verify_lifetime?
    !token_expiry_time.nil?
  end
end
