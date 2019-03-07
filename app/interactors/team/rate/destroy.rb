class Team::Rate::Destroy < ApplicationInteractor
  object :rate

  def execute
    rate.destroy
  end
end
