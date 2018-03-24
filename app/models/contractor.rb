class Contractor < ApplicationRecord
  include EnsureUUID
  include HasMember

  belongs_to :workspace, inverse_of: :contractors, class_name: 'Workspace'

  has_many :contractor_rates,
           class_name: 'Rate::Contractor',
           dependent: :delete_all,
           foreign_key: :owner_id,
           inverse_of: :owner

  validates :currency, presence: true, length: { is: 3 }
  validates :email, email: true, allow_blank: true

  def rates
    contractor_rates.
      union(workspace.default_contractor_rates).
      without_duplicates
  end
end
