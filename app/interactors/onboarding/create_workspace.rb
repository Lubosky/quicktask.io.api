class Onboarding::CreateWorkspace < ApplicationInteractor
  string :name
  string :slug, default: nil

  def execute
    transaction do
      create_workspace
      create_workspace_roles
      create_team_member
      create_workspace_user
    end
    workspace
  end

  private

  def create_team_member
    unless team_member.save
      errors.merge!(team_member.errors)
      rollback
    end
  end

  def create_workspace
    unless workspace.save
      errors.merge!(workspace.errors)
      rollback
    end
  end

  def create_workspace_roles
    Rolify::Base.create_for(workspace)
  end

  def create_workspace_user
    unless workspace_user.save
      errors.merge!(workspace_user.errors)
      rollback
    end
  end

  def role
    @role ||= workspace.roles.find_by(permission_level: :owner)
  end

  def team_member
    @team_member ||= TeamMember.new(team_member_attributes)
  end

  def user
    @user ||= current_user
  end

  def workspace
    @workspace ||= Workspace.new(workspace_attributes)
  end

  def workspace_user
    @workspace_user ||= WorkspaceUser.new(workspace_user_attributes)
  end

  def team_member_attributes
    {}.tap do |hash|
      hash[:first_name] = user.first_name
      hash[:last_name] = user.last_name
      hash[:workspace] = workspace
    end
  end

  def workspace_attributes
    attributes.slice(:name, :slug).tap do |hash|
      hash[:owner] = user
    end
  end

  def workspace_user_attributes
    {}.tap do |hash|
      hash[:member] = team_member
      hash[:role] = role
      hash[:user] = user
      hash[:workspace] = workspace
    end
  end
end
