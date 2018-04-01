class Tasklist < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  with_options inverse_of: :tasklists do
    belongs_to :project
    belongs_to :workspace
  end

  belongs_to :owner, class_name: 'WorkspaceUser', inverse_of: :owned_tasklists

  has_many :tasks, dependent: :destroy, inverse_of: :tasklist

  belongs_directly_to :workspace

  acts_as_list scope: :project

  accepts_nested_attributes_for :tasks, allow_destroy: true

  validates :project, :title, :workspace, presence: true

  delegate :workspace, to: :project

  before_validation { self.title&.strip! }
end
