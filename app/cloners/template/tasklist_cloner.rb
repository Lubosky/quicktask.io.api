class Template::TasklistCloner < Clowne::Cloner
  adapter :active_record

  include_association :tasks, clone_with: ::Template::TaskCloner, params: true

  nullify :uuid, :task_count, :completed_task_count, :position

  finalize do |source, record, params|
    record.owner = params[:owner]
    record.completed_task_count = 0
    record.task_count = 0
  end
end
