module HasMember
  extend ActiveSupport::Concern

  included do
    has_one :workspace_user, as: :member, inverse_of: :member, dependent: :destroy
    has_one :workspace,
            through: :workspace_user,
            as: :member,
            inverse_of: :member,
            class_name: 'Workspace',
            foreign_key: :workspace_id

    has_one :user, through: :workspace_user

    delegate :language, :time_zone, :time_twelve_hour, to: :user, allow_nil: true
  end
end
