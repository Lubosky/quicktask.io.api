class Team::Tasklist::Destroy < ApplicationInteractor
  object :tasklist

  def execute
    tasklist.destroy
  end
end
