class SignupToken
  class EmailInvalidError < StandardError; end
  class EmailRegisteredError < StandardError; end
  class InvalidToken < StandardError; end

  class_attribute :token_expiry_time
  self.token_expiry_time = 12.hours

  def self.generate_for(email)
    raise EmailRegisteredError if User.where(email: email).exists?

    token = Vault.encrypt([
      email,
      token_expiry_time.from_now
    ])

    new(token)
  end

  def initialize(token)
    @token = token.to_s
  end

  def email
    digested_email, expires_at = decrypt_and_verify

    raise EmailRegisteredError if User.where(email: digested_email).exists?

    return digested_email if expires_at.future?
  end

  def to_s
    token
  end

  private

  attr_reader :token

  def decrypt_and_verify
    Vault.decrypt(token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    [nil, 1.hour.ago]
  end
end
