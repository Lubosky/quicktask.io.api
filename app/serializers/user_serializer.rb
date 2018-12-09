class UserSerializer < BaseSerializer
  set_id    :id
  set_type  :user

  attribute :email
  attribute :status
  attribute :first_name
  attribute :last_name
  # TODO: Add Shrine
  # attribute :avatar

  attribute :language
  attribute :timezone do |object|
    object.time_zone
  end
  attribute :settings
end
