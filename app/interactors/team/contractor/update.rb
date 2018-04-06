class Team::Contractor::Update < ApplicationInteractor
  object :contractor

  string :email, default: nil
  string :first_name, default: nil
  string :last_name, default: nil
  string :business_name, default: nil
  string :phone, default: nil

  string :currency, default: -> { current_workspace.currency }

  def execute
    transaction do
      unless contractor.update(given_attributes.except(:contractor))
        errors.merge!(contractor.errors)
        rollback
      end
    end
    contractor
  end
end
