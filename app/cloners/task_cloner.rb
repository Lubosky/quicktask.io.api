class TaskCloner < Clowne::Cloner
  adapter :active_record

  include_association :todos, clone_with: TodoCloner

  nullify :start_date, :due_date, :completed_date, :position, :status, :uuid

  finalize do |source, record, clone_directly: false|
    cloned_title = [
      source.title,
      I18n.t('common.copy_in_brackets')
    ].delete_if { |a| a.blank? }.join(' ').strip

    title = clone_directly ? cloned_title : source.title
    timestamp = Time.current.beginning_of_hour + 1.hour

    record.title = title
    record.start_date = timestamp
    record.status = :uncompleted

    if source.start_date && source.due_date
      duration = source.due_date - source.start_date

      record.due_date = timestamp + duration
    end
  end
end
