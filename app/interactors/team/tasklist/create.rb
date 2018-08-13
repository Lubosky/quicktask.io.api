class Team::Tasklist::Create < ApplicationInteractor
  object :project

  string :title

  def execute
    transaction do
      unless tasklist.save
        errors.merge!(tasklist.errors)
        rollback
      end
    end
    tasklist
  end

  private

  def tasklist
    @tasklist ||= project.tasklists.build(tasklist_attributes.except(:project))
  end

  def tasklist_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user.member
    end
  end
end
