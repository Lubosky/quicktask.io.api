class Template::ProjectCloner < Clowne::Cloner
  adapter :active_record

  init_as { |source, _target| ::Project::Regular.new(workspace: source.workspace) }

  include_association :tasklists, clone_with: ::Template::TasklistCloner, params: true

  nullify :uuid,
          :identifier,
          :status,
          :task_count,
          :completed_task_count,
          :completion_ratio,
          :start_date,
          :due_date,
          :completed_date,
          :billed


  finalize do |source, record, owner:, client:, name:|
    timestamp = Time.current.beginning_of_hour + 1.hour

    record.owner = owner
    record.client = client
    record.project_type = :regular
    record.name = name
    record.status = :draft
    record.task_count = 0
    record.completed_task_count = 0
    record.completion_ratio = 0.0
    record.billed = false
    record.start_date = timestamp

    if source.start_date && source.due_date
      duration = source.due_date - source.start_date

      record.due_date = timestamp + duration
    end
  end
end
