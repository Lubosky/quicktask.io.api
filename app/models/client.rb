class Client < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :clients

  with_options inverse_of: :client, dependent: :restrict_with_error do
    has_many :client_contacts
    has_many :projects
    has_many :project_groups, through: :projects
  end

  validates :currency, presence: true, length: { is: 3 }

  jsonb_accessor :tax_settings,
    tax_number: :string,
    tax_rate: :float
end
