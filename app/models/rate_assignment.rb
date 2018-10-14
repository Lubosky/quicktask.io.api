class RateAssignment < ApplicationRecord
  belongs_to :contractor, foreign_key: :contractor_id, inverse_of: :rate_assignments
  belongs_to :rate, foreign_key: :rate_id, inverse_of: :rate_assignment

  validates :contractor, :rate, presence: true
end
