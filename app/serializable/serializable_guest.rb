class SerializableGuest < SerializableBase
  type :user

  attribute :email
  attribute :first_name
  attribute :last_name
  attribute :locale
  attribute :settings
  attribute :status
  attribute :timezone do
    @object.time_zone
  end
end
