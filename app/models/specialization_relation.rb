class SpecializationRelation < ApplicationRecord
  belongs_to :specializable, polymorphic: true
  belongs_to :specialization

  has_one :workspace, through: :specialization

  validates :specializable, :specialization, presence: true
  validates :specialization_id, uniqueness: {
    scope: %i[specializable_id specializable_type]
  }
end
