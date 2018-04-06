class Team::Contractor::Create < ApplicationInteractor
  string :email
  string :first_name, default: ''
  string :last_name, default: ''
  string :business_name, default: nil
  string :phone, default: nil

  string :currency, default: -> { current_workspace.currency }

  validates :email, :currency, presence: true

  def execute
    transaction do
      unless contractor.save
        errors.merge!(contractor.errors)
        rollback
      end
    end
    contractor
  end

  private

  def contractor
    @contractor ||= current_workspace.contractors.build(attributes)
  end
end
