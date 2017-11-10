class SerializableWorkspace < SerializableBase
  type :workspace

  attribute :owner_id
  attribute :customer_id do
    @object.stripe_customer_id
  end

  attribute :name
  attribute :slug
  attribute :status
  attribute :business_name
  attribute :business_data
  # TODO: Add Shrine
  # attribute :logo

  attribute :team_member_count
  attribute :team_member_limit
  attribute :stats
end
