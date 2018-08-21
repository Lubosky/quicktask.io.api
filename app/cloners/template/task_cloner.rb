class Template::TaskCloner < Clowne::Cloner
  adapter :active_record

  include_association :todos, clone_with: ::Template::TodoCloner

  nullify :uuid, :status, :start_date, :due_date, :completed_date, :position

  finalize do |source, record, params|
    timestamp = Time.current.beginning_of_hour + 1.hour

    record.owner = params[:owner]
    record.status = :uncompleted
    record.start_date = timestamp

    if source.start_date && source.due_date
      duration = source.due_date - source.start_date

      record.due_date = timestamp + duration
    end
  end
end
