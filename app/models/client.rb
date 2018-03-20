class Client < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :clients

  with_options dependent: :restrict_with_error, inverse_of: :client do
    has_many :client_contacts
    has_many :project_groups, through: :projects
    has_many :projects, through: :workspace
  end

  validates :currency, presence: true, length: { is: 3 }

  jsonb_accessor :tax_settings,
    tax_number: :string,
    tax_rate: :float
end
