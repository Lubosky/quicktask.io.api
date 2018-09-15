class Team::Tasklist::Create < ApplicationInteractor
  object :parent, class: Project

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
    @tasklist ||= parent.tasklists.build(tasklist_attributes.except(:parent))
  end

  def tasklist_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user.member
    end
  end
end
