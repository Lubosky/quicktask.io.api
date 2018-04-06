class Team::Client::Create < ApplicationInteractor
  string :name
  string :email, default: nil
  string :phone, default: nil
  string :tax_number, default: nil
  string :currency, default: -> { current_workspace.currency }

  validates :name, :currency, presence: true

  def execute
    transaction do
      unless client.save
        errors.merge!(client.errors)
        rollback
      end
    end
    client
  end

  private

  def client
    @client ||= current_workspace.clients.build(attributes)
  end
end
