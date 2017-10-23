class SerializableUser < SerializableBase
  type :user

  attribute :email
  attribute :first_name
  attribute :last_name
end
