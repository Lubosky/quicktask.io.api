class PasswordResetToken
  class InvalidToken < StandardError; end

  class_attribute :password_reset_time_limit
  self.password_reset_time_limit = 10.minutes

  def self.generate_for(user)
    token = Vault.encrypt(
      [
        user.id,
        Digest::SHA256.hexdigest(user.password_digest),
        password_reset_time_limit.from_now
      ]
    )

    new(token)
  end

  def initialize(token)
    @token = token.to_s
  end

  def user
    user_id, digested_secret, expires_at = decrypt_and_verify

    if expires_at.future?
      user = User.find_by(id: user_id)

      if digested_secret == Digest::SHA256.hexdigest(user.password_digest)
        user
      end
    end
  end

  def to_s
    token
  end

  private

  attr_reader :token

  def decrypt_and_verify
    Vault.decrypt(token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    [nil, nil, 1.hour.ago]
  end
end
