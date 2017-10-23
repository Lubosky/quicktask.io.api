module EnsureUUID
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid

    private

    def ensure_uuid
      set_uuid = uuid.blank?
      self.uuid = BSON::ObjectId.new if set_uuid
    end
  end
end
