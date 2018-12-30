class ClientRequest::Localization < ClientRequest
  set_request_type :localization

  VALIDATABLE_FIELDS = COMMON_FIELDS + %w(target_language_ids)

  before_validation { self.source_language = nil }

  validates :target_language_ids, presence: true, unless: :draft?

  def target_language_ids=(value)
    collection_ids = self.workspace.languages.where(id: value).ids
    write_attribute(:target_language_ids, collection_ids)
  end

  def submittable_fields
    attributes.keys & VALIDATABLE_FIELDS
  end

  private

  def calculate_estimated_cost
    estimated_price = Estimator::Localization.estimate_price(self)
    self.estimated_cost = estimated_price
  end
end
