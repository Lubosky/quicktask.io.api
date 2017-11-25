class WorkspaceUser < ApplicationRecord
  self.table_name = :organization_accounts

  include EnsureUUID

  belongs_to :member, polymorphic: true
  belongs_to :role, class_name: 'Role::Base'
  belongs_to :user
  belongs_to :workspace

  validates_presence_of :member, :role, :user, :workspace
  validates_uniqueness_of :user_id, scope: [:member_type, :member_id]
  validate :member_allowed_for_role?, if: :role_id_changed?

  delegate :first_name, :last_name, :locale, :time_zone, :settings, to: :user
  delegate :permission_level, to: :role

  def client?
    symbolized_member_type == :client_contact
  end

  def contractor?
    symbolized_member_type == :contractor
  end

  def team_member?
    symbolized_member_type == :team_member
  end

  def allowed_to?(action)
    self.role.has_permission?(action)
  end

  def currency
    case symbolized_member_type
    when :team_member
      workspace&.currency
    when :contractor
      member&.currency
    when :client_contact
      member&.client&.currency
    end
  end

  private

  def symbolized_member_type
    member_type.underscore.to_sym
  end

  def member_allowed_for_role?
    case symbolized_member_type
    when :team_member
      errors.add(:role, :invalid) unless self.permission_level.to_sym.in?([:member, :owner])
    when :contractor
      errors.add(:role, :invalid) unless self.permission_level.to_sym == :collaborator
    when :client
      errors.add(:role, :invalid) unless self.permission_level.to_sym == :client_contact
    end
  end
end
