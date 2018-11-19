class Team::HandOff::Accept < ApplicationInteractor
  object :hand_off

  string :email, default: -> { assignee.email }
  string :first_name, default: -> { assignee.first_name }
  string :last_name, default: -> { assignee.last_name }
  string :password, default: nil

  validates :email, :first_name, :last_name, :password, presence: true, unless: :has_workspace_account?

  def execute
    transaction do
      unless hand_off.accept!
        errors.merge!(hand_off.errors)
        rollback
      end

      unless has_workspace_account?
        create_user
        create_workspace_account
      end
    end
    deliver_email
    hand_off
  end

  private

  def deliver_email
    return unless hand_off.accepted?
    mail = HandOffMailer.acceptance_email(hand_off: hand_off)
    mail.deliver_later
  end

  def create_workspace_account
    unless workspace_account.save
      errors.merge!(workspace_account.errors)
      rollback
    end

    workspace_account.activate if workspace_account.valid?
  end

  def create_user
    unless user.save
      errors.merge!(user.errors)
      rollback
    end
  end

  def assignee
    @assignee ||= hand_off.assignee
  end

  def has_workspace_account?
    assignee.workspace_account.present?
  end

  def permission_level
    assignee.is_a?(Contractor) ? :collaborator : :member
  end

  def role
    @role ||= workspace.roles.find_by(permission_level: permission_level)
  end

  def user
    @user ||= User.new(user_attributes)
  end

  def workspace_account
    @workspace_account ||= WorkspaceAccount.new(workspace_account_attributes)
  end

  def workspace
    @workspace ||= hand_off.workspace
  end

  def workspace_account_attributes
    {}.tap do |hash|
      hash[:account] = assignee
      hash[:role] = role
      hash[:user] = user
      hash[:workspace] = workspace
    end

    def user_attributes
      attributes.slice(:email, :first_name, :last_name, :password)
    end
  end
end


