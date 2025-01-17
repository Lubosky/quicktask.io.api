class Team::Task::Duplicate < ApplicationInteractor
  object :task

  def execute
    cloned = ::TaskCloner.call(task, clone_directly: true)

    transaction do
      unless cloned.save!
        errors.merge!(cloned.errors)
        rollback
      end
    end

    cloned.reload if cloned.valid?
    cloned
  end
end
