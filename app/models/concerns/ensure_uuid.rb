module EnsureUUID
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid, on: :create

    validates_presence_of :uuid
    validates_uniqueness_of :uuid, on: :create

    private

    def ensure_uuid
      set_uuid = uuid.blank?
      self.uuid = BSON::ObjectId.new if set_uuid
    end
  end
end
