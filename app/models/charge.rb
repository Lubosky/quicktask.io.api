class Charge < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :charges

  has_one :membership, through: :workspace, inverse_of: :charges

  validates :workspace_id, presence: true
  validates :stripe_invoice_id, presence: true, uniqueness: true

  jsonb_accessor :source,
    type: :string,
    brand: :string,
    exp_month: :integer,
    exp_year: :integer,
    last4: :string
end
