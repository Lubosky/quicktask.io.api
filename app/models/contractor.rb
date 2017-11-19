class Contractor < ApplicationRecord
  include EnsureUUID
  include HasMember

  belongs_to :workspace, inverse_of: :contractors, class_name: 'Workspace'

  validates :currency, presence: true, length: { is: 3 }
  validates :email, email: true, allow_blank: true
end
