class TasklistCloner < Clowne::Cloner
  adapter :active_record

  include_association :tasks, clone_with: TaskCloner

  nullify :task_count, :completed_task_count, :position, :uuid

  finalize do |source, record, clone_directly: false|
    cloned_title = [
      source.title,
      I18n.t('common.copy_in_brackets')
    ].delete_if { |a| a.blank? }.join(' ').strip

    title = clone_directly ? cloned_title : source.title

    record.title = title
    record.completed_task_count = 0
    record.task_count = 0
  end
end
