module HasName
  extend ActiveSupport::Concern

  included do
    def name
      return business_name if self.is_a?(Contractor) && self.business_name.present?
      return [first_name, last_name].compact.join(' ').strip! if first_name.present? || last_name.present?
      return email
    end
  end
end
