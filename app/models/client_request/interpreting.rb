class ClientRequest::Interpreting < ClientRequest
  set_request_type :interpreting

  include HasLocation

  jsonb_accessor :request_data,
    equipment_needed: [:boolean, default: false],
    interpreter_count: [:integer, default: 1]

  before_validation { self.unit = self.default_unit }

  validates :interpreter_count,
            numericality: { greater_than: 0, only_integer: true }
  validates :source_language, :target_language_ids, presence: true

  def unit_count=(value)
    return super unless start_date && due_date
    time_difference = TimeDifference.between(start_date, due_date).in_hours
    write_attribute(:unit_count, time_difference)
  end

  def target_language_ids=(value)
    collection_ids = self.workspace.languages.where(id: value).ids
    collection_ids = collection_ids.without(source_language_id)
    write_attribute(:target_language_ids, collection_ids)
  end

  def default_unit
    workspace.units.with_type(:time).find_by(deletable: false)
  end

  private

  def calculate_estimated_cost
    estimated_price = Estimator::Interpreting.estimate_price(self)
    self.estimated_cost = estimated_price
  end
end
