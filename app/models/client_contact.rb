class ClientContact < ApplicationRecord
  include EnsureUUID
  include HasMember

  belongs_to :client, inverse_of: :client_contacts
  belongs_to :workspace, inverse_of: :client_contacts

  validates :email, email: true, allow_blank: true
end
