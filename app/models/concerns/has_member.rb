module HasMember
  extend ActiveSupport::Concern

  included do
    has_one :workspace_account, as: :account, inverse_of: :account, dependent: :destroy
    has_one :workspace,
            through: :workspace_account,
            as: :account,
            inverse_of: :account,
            class_name: 'Workspace',
            foreign_key: :workspace_id

    has_one :user, through: :workspace_account

    delegate :language, :time_zone, :time_twelve_hour, to: :user, allow_nil: true
  end
end
