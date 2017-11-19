class Client < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :clients

  has_many :client_contacts, inverse_of: :client, dependent: :restrict_with_error

  validates :currency, presence: true, length: { is: 3 }

  jsonb_accessor :tax_settings,
    tax_number: :string,
    tax_rate: :float
end
