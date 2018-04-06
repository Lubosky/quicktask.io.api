class Team::Contractor::Destroy < ApplicationInteractor
  object :contractor

  def execute
    contractor.destroy
  end
end
