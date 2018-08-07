class Team::Tasklist::MoveTasklist < ApplicationInteractor
  object :tasklist

  integer :position, default: 0

  def execute
    transaction do
      unless tasklist.update(given_attributes.except(:tasklist))
        errors.merge!(tasklist.errors)
        rollback
      end
    end
    tasklist
  end
end




