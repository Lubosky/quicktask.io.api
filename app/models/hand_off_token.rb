class HandOffToken
  class InvalidToken < StandardError; end
  class ExpiredToken < StandardError; end

  def self.generate_for(hand_off)
    token = Vault.encrypt(
      [
        hand_off.id,
        Digest::SHA256.hexdigest(hand_off.uuid),
        hand_off.valid_through
      ]
    )

    new(token)
  end

  def initialize(token)
    @token = token.to_s
  end

  def hand_off
    hand_off_id, digested_secret, expires_at = decrypt_and_verify

    raise ExpiredToken unless expires_at.nil? || expires_at.future?

    hand_off = HandOff.find_by(id: hand_off)

    raise HandOff::HandOffExpired unless hand_off.pending?

    if digested_secret == Digest::SHA256.hexdigest(hand_off.uuid)
      hand_off
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
