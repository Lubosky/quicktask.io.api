class Vault
  def self.encrypt(value)
    crypt.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    crypt.decrypt_and_verify(value)
  end

  private_class_method

  def self.crypt
    @_crypt ||= begin
      key_generator = ActiveSupport::KeyGenerator.new(ENV['SECRET_KEY_BASE'])
      key = key_generator.generate_key(ENV['SECRET_SALT'], 32)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
