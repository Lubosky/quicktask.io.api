class Team::Client::Destroy < ApplicationInteractor
  object :client

  def execute
    client.destroy
  end
end
