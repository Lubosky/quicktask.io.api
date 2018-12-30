class ClientRequest::Translation < ClientRequest
  set_request_type :translation

  VALIDATABLE_FIELDS = COMMON_FIELDS + %w(source_language target_language_ids)

  validates :source_language, :target_language_ids, presence: true, unless: :draft?

  def target_language_ids=(value)
    collection_ids = self.workspace.languages.where(id: value).ids
    collection_ids = collection_ids.without(source_language_id)
    write_attribute(:target_language_ids, collection_ids)
  end

  def submittable_fields
    attributes.keys & VALIDATABLE_FIELDS
  end

  private

  def calculate_estimated_cost
    estimated_price = Estimator::Translation.estimate_price(self)
    self.estimated_cost = estimated_price
  end
end
