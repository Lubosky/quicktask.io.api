module EnsureUUID
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid, on: :create

    validates :uuid, presence: true, uniqueness: true

    private

    def ensure_uuid
      self.uuid = BSON::ObjectId.new if uuid.blank?
    end
  end
end
