class Elastic::TaskSerializer < BaseSerializer
  set_id    :id
  set_type  :task

  attribute :id
  attribute :workspace_id do |o|
    o.workspace_id.to_s
  end

  attribute :owner_id do |o|
    o.owner_id.to_s
  end

  attribute :assignee_id do |o|
    o.assignee_id.to_s
  end

  attribute :project_id do |o|
    o.project_id.to_s
  end

  attribute :tasklist_id do |o|
    o.tasklist_id.to_s
  end

  attribute :source_language_id do |o|
    o.source_language_id.to_s
  end

  attribute :target_language_id do |o|
    o.target_language_id.to_s
  end

  attribute :task_type_id do |o|
    o.task_type_id.to_s
  end

  attribute :unit_id do |o|
    o.unit_id.to_s
  end

  attributes :title,
             :description,
             :status,
             :completed_status,
             :owner_name,
             :assignee_name,
             :project_name,
             :tasklist_title,
             :source_language,
             :target_language,
             :task_type,
             :unit,
             :classification,
             :internal,
             :start_date,
             :due_date,
             :completed_date,
             :created_at,
             :updated_at
end
