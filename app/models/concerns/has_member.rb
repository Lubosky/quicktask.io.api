module HasMember
  extend ActiveSupport::Concern

  included do
    has_one :workspace_account, as: :profile, inverse_of: :profile, dependent: :destroy
    has_one :workspace,
            through: :workspace_account,
            as: :profile,
            inverse_of: :profile,
            class_name: 'Workspace',
            foreign_key: :workspace_id

    has_one :user, through: :workspace_account

    delegate :language, :time_zone, :time_twelve_hour, to: :user, allow_nil: true
  end
end
