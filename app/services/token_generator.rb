class TokenGenerator
  def self.generate_token(length: 90)
    new(length).generate_token
  end

  def initialize(length)
    @length = length.to_i
  end

  def generate_token
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  private

  attr_reader :length
end
