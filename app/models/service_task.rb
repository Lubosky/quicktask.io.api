class ServiceTask < ApplicationRecord
  with_options inverse_of: :service_tasks do
    belongs_to :service
    belongs_to :task_type
  end

  has_one :workspace, through: :service

  validates :service, :task_type, presence: true

  acts_as_list scope: :service, top_of_list: 0
end
