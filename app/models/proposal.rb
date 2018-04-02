class Proposal < ApplicationRecord
  belongs_to :client_request
  belongs_to :quote

  validates :client_request, :quote, presence: true
  validates :client_request_id, uniqueness: { scope: :quote_id }
end
