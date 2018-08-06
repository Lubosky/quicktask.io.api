class PasswordGenerator
  def self.generate_password(length: 18)
    new(length).generate_password
  end

  def initialize(length)
    @length = length.to_i
  end

  def generate_password
    ::BCrypt::Password.create(passphrase)
  end

  private

  attr_reader :length

  def passphrase
    ::TokenGenerator.generate_token(length: length)
  end
end
