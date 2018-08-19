class TodoCloner < Clowne::Cloner
  adapter :active_record

  nullify :completed, :completed_date, :due_date, :position, :uuid

  finalize do |source, record, _params|
    parent = record.task

    if source.due_date
      duration = source.due_date - parent.start_date
      timestamp = Time.current.beginning_of_hour + 1.hour

      record.due_date = timestamp + duration
    end
  end
end
