class ClientContact < ApplicationRecord
  include EnsureUUID
  include HasMember
  include HasName

  with_options inverse_of: :client_contacts do
    belongs_to :client
    belongs_to :workspace
  end

  has_many :client_requests, inverse_of: :requester

  validates :email, email: true, allow_blank: true
end
