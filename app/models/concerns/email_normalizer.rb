module EmailNormalizer
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_email

    def self.find_by_normalized_email(email)
      find_by_email normalize_email(email)
    end

    def self.normalize_email(email)
      email.to_s.downcase.gsub(/\s+/, '')
    end

    private

    def normalize_email
      self.email = self.class.normalize_email(email)
    end
  end
end
