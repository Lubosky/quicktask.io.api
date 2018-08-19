class TasklistCloner < Clowne::Cloner
  adapter :active_record

  include_association :tasks, clone_with: TaskCloner

  nullify :task_count, :completed_task_count, :position, :uuid

  finalize do |_source, record, _params|
    record.completed_task_count = 0
    record.task_count = 0
end
end
