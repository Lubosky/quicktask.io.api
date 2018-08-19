class Team::Task::Duplicate < ApplicationInteractor
  integer :task_id

  def execute
    cloned = ::TaskCloner.call(project)

    transaction do
      unless cloned.save!
        errors.merge!(cloned.errors)
        rollback
      end
    end

    cloned.reload if cloned.valid?
    cloned
  end

  private

  def task
    @_task ||= ::Task.with_preloaded.find_by(id: task_id)
  end
end
