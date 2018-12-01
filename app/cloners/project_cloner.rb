class ProjectCloner < Clowne::Cloner
  adapter :active_record

  include_association :tasklists, clone_with: TasklistCloner

  nullify :billed,
          :completion_ratio,
          :completed_task_count,
          :identifier,
          :start_date,
          :due_date,
          :completed_date,
          :status,
          :task_count,
          :uuid

  finalize do |source, record, _params|
    name = [source.name, I18n.t('common.copy_in_brackets')].delete_if { |a| a.blank? }.join(' ').strip
    timestamp = Time.current.beginning_of_hour + 1.hour

    record.name = name
    record.workflow_type = source.workflow_type
    record.billed = false
    record.status = :draft
    record.completion_ratio = 0.0
    record.task_count = 0
    record.completed_task_count = 0
    record.start_date = timestamp

    if source.start_date && source.due_date
      duration = source.due_date - source.start_date

      record.due_date = timestamp + duration
    end
  end
end
