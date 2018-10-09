class Team::Tasklist::Duplicate < ApplicationInteractor
  object :tasklist

  def execute
    cloned = ::TasklistCloner.call(tasklist, clone_directly: true)

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
