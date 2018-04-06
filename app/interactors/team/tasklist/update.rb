class Team::Tasklist::Update < ApplicationInteractor
  object :tasklist

  string :title, default: nil

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
