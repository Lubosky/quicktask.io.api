class Team::Project::Duplicate < ApplicationInteractor
  integer :project_id

  def execute
    cloned = ::ProjectCloner.call(project)

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

  def project
    @_project ||= ::Project.with_preloaded.find_by(id: project_id)
  end
end
