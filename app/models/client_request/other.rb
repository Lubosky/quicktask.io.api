class ClientRequest::Other < ClientRequest
  set_request_type :other

  before_validation { self.source_language = nil }

  def target_language_ids=(value)
    write_attribute(:target_language_ids, [])

  end

  private

  def calculate_estimated_cost
    estimated_price = Estimator::Other.estimate_price(self)
    self.estimated_cost = estimated_price
  end
end
