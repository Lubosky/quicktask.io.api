class SerializableUser < SerializableBase
  type :user

  attribute :email
  attribute :status
  attribute :first_name
  attribute :last_name
  # TODO: Add Shrine
  # attribute :avatar

  attribute :locale
  attribute :timezone do
    @object.time_zone
  end
  attribute :settings
end
