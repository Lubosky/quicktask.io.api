class ProjectTemplateBuilder
  def self.create_for(workspace_account, workspace)
    new(workspace_account, workspace).call
  end

  def initialize(workspace_account, workspace)
    @team_member = workspace_account.profile
    @workspace = workspace
  end

  def call
    workspace.project_templates.create(template_attributes)
  end

  private

  attr_reader :team_member, :workspace

  def template_attributes
    [kanban_attributes, team_attributes, weekday_attributes]
  end

  def kanban_attributes
    {}.tap do |hash|
      hash[:owner] = team_member
      hash[:template_name] = I18n.t('kanban.name', scope: 'templates.project.workflow')
      hash[:template_description] = I18n.t('kanban.description', scope: 'templates.project.workflow')
      hash[:system_template] = true
      hash[:workflow_template] = :kanban
      hash[:tasklists_attributes] = [:todo, :doing, :done].map do |key|
        {}.tap do |subhash|
          subhash[:owner] = team_member
          subhash[:title] = I18n.t("kanban.#{key.to_s}", scope: 'templates.project.workflow')
        end
      end
    end
  end

  def team_attributes
    {}.tap do |hash|
      hash[:owner] = team_member
      hash[:template_name] = I18n.t('team.name', scope: 'templates.project.workflow')
      hash[:template_description] = I18n.t('team.description', scope: 'templates.project.workflow')
      hash[:system_template] = true
      hash[:workflow_template] = :team
    end
  end

  def weekday_attributes
    {}.tap do |hash|
      hash[:owner] = team_member
      hash[:template_name] = I18n.t('weekday.name', scope: 'templates.project.workflow')
      hash[:template_description] = I18n.t('weekday.description', scope: 'templates.project.workflow')
      hash[:system_template] = true
      hash[:workflow_template] = :weekday
      hash[:tasklists_attributes] = [:monday, :tuesday, :wednesday, :thursday, :friday].map do |key|
        {}.tap do |subhash|
          subhash[:owner] = team_member
          subhash[:title] = I18n.t("weekday.#{key.to_s}", scope: 'templates.project.workflow')
        end
      end
    end
  end
end
