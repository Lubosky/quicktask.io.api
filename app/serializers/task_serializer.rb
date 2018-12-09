class TaskSerializer < BaseSerializer
  set_id    :id
  set_type  :task

  attributes :workspace_id,
             :project_id,
             :tasklist_id,
             :owner_id,
             :source_language_id,
             :target_language_id,
             :task_type_id,
             :unit_id,
             :title,
             :description,
             :color,
             :status,
             :start_date,
             :due_date,
             :completed_date,
             :unit_count,
             :completed_unit_count,
             :attachment_count,
             :comment_count,
             :position,
             :task_data,
             :metadata

  belongs_to :project
end
