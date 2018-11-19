class Onboarding::CreateWorkspace < ApplicationInteractor
  string :name

  def execute
    transaction do
      create_workspace
      create_workspace_roles
      create_languages
      create_specializations
      create_task_types
      create_units
      create_units
      account = create_workspace_account
      create_project_templates(account)
    end
    workspace
  end

  private

  def create_languages
    Language.create_for(workspace)
  end

  def create_project_templates(account)
    ::ProjectTemplateBuilder.create_for(account, workspace)
  end

  def create_specializations
    WorkspaceSpecialization.create_for(workspace)
  end

  def create_task_types
    TaskType.create_for(workspace)
  end

  def create_team_member
    unless team_member.save
      errors.merge!(team_member.errors)
      rollback
    end
  end

  def create_units
    Unit.create_for(workspace)
  end

  def create_workspace
    unless workspace.save
      errors.merge!(workspace.errors)
      rollback
    end
  end

  def create_workspace_roles
    Role::Base.create_for(workspace)
  end

  def create_workspace_account
    unless workspace_account.save
      errors.merge!(workspace_account.errors)
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

  def workspace_account
    @workspace_account ||= WorkspaceAccount.new(workspace_account_attributes)
  end

  def team_member_attributes
    {}.tap do |hash|
      hash[:first_name] = user.first_name
      hash[:last_name] = user.last_name
      hash[:workspace] = workspace
    end
  end

  def workspace_attributes
    attributes.slice(:name).tap do |hash|
      hash[:owner] = user
    end
  end

  def workspace_account_attributes
    {}.tap do |hash|
      hash[:account] = team_member
      hash[:role] = role
      hash[:user] = user
      hash[:workspace] = workspace
    end
  end
end
