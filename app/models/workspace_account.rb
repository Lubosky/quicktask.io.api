class WorkspaceAccount < ApplicationRecord
  self.table_name = :organization_accounts

  include EnsureUUID

  belongs_to :profile, polymorphic: true
  belongs_to :role, class_name: 'Role::Base'
  belongs_to :user
  belongs_to :workspace

  has_many :assigned_todos, class_name: 'Todo',
           foreign_key: :assignee_id,
           inverse_of: :assignee

  jsonb_accessor :workspace_settings,
    project_sort_option: [:integer, default: 0],
    project_view_type: [:integer, default: 0],
    task_view_type: [:integer, default: 0]

  validates :profile,
            :project_sort_option,
            :project_view_type,
            :role,
            :task_view_type,
            :user,
            :workspace,
            presence: true

  validates_uniqueness_of :user_id, scope: [:profile_type, :profile_id]
  validate :profile_allowed_for_role?, if: :role_id_changed?

  delegate :first_name, :last_name, :email, :locale, :time_zone, :settings, to: :user
  delegate :permission_level, :permissions, to: :role

  enum project_sort_option: { due_date: 0, identifier: 1, title: 2, updated_at: 3 }, _prefix: true
  enum project_view_type: { grid: 0, list: 1 }, _prefix: true
  enum task_view_type: { column: 0, list: 1 }, _prefix: true

  enum status: { pending: 0, active: 1, deactivated: 2 } do
    event :activate do
      transition all - [:active] => :active
    end

    event :deactivate do
      transition all - [:deactivated] => :deactivated
    end
  end

  def client?
    symbolized_profile_type == :client_contact
  end

  def contractor?
    symbolized_profile_type == :contractor
  end

  def team_member?
    symbolized_profile_type == :team_member
  end

  def allowed_to?(action)
    self.role.has_permission?(action)
  end

  def currency
    case symbolized_profile_type
    when :team_member
      workspace&.currency
    when :contractor
      profile&.currency
    when :client_contact
      profile&.client&.currency
    end
  end

  def synchronize_common_attributes
    self.profile.tap do |entity|
      entity.first_name = self.first_name
      entity.last_name = self.last_name
      entity.email = self.email
      entity.save
    end
  end

  private

  def symbolized_profile_type
    profile_type.underscore.to_sym
  end

  def profile_allowed_for_role?
    case symbolized_profile_type
    when :team_member
      errors.add(:role, :invalid) unless self.permission_level.to_sym.in?([:profile, :owner])
    when :contractor
      errors.add(:role, :invalid) unless self.permission_level.to_sym == :collaborator
    when :client
      errors.add(:role, :invalid) unless self.permission_level.to_sym == :client_contact
    end
  end
end
