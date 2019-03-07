class Team::Rate::Update < ApplicationInteractor
  object :rate

  integer :source_language_id, default: nil
  integer :target_language_id, default: nil
  integer :task_type_id, default: nil
  integer :unit_id, default: nil
  decimal :price, default: nil

  def execute
    transaction do
      unless rate.update(given_attributes.except(:rate))
        errors.merge!(rate.errors)
        rollback
      end
    end
    rate
  end
end
