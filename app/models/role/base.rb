class Role::Base < ApplicationRecord
  self.table_name = :organization_roles

  include EnsureUUID

  PERMISSION_LEVEL_ABILITIES = YAML.load_file(Rails.root.join('config', 'fixtures', 'permissions.yml'))

  belongs_to :workspace, foreign_key: :workspace_id

  has_many :members, through: :workspace, class_name: 'WorkspaceUser'

  discriminate Role, on: :permission_level

  before_destroy :check_deletable

  validates :permission_level, presence: true
  validates :name, presence: true, uniqueness: { scope: :workspace_id }, length: { maximum: 45 }
  validate :permission_allowed_for_role?

  def has_permission?(permission)
    !permissions.empty? && access_permissions.include?(permission.to_sym)
  end

  def self.set_permission_level(type)
    after_initialize { self.permission_level = type }
  end

  def self.build_for(workspace)
    workspace.roles.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.roles.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'roles.yml'))
  end

  private

  def access_permissions
    permissions.map(&:to_sym)
  end

  def allowed_permissions
    @allowed_permissions ||= PERMISSION_LEVEL_ABILITIES[self.permission_level]
  end

  def check_deletable
    errors.add(:base, 'Can\'t delete an account owner\'s role') if permission_level.to_sym == :owner
    errors.add(:base, 'Can\'t delete a role') if members.exists?
    errors.add(:base, 'Can\'t delete a default role') if default?
  end

  def permission_allowed_for_role?
    if !permissions.is_a?(Array) || permissions.detect { |permission| !permission.in?(allowed_permissions) }
      errors.add(:permissions, :invalid)
    end
  end
end
