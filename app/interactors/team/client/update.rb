class Team::Client::Update < ApplicationInteractor
  object :client

  string :name, default: nil
  string :email, default: nil
  string :phone, default: nil
  string :tax_number, default: nil
  string :currency, default: -> { current_workspace.currency }

  def execute
    transaction do
      unless client.update(given_attributes.except(:client))
        errors.merge!(client.errors)
        rollback
      end
    end
    client
  end
end
