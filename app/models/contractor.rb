class Contractor < ApplicationRecord
  include EnsureUUID
  include HasMember

  belongs_to :workspace, inverse_of: :contractors, class_name: 'Workspace'
end
