class GuestSerializer < BaseSerializer
  set_id    :id
  set_type  :user

  attributes :email,
             :first_name,
             :last_name,
             :locale,
             :settings,
             :status

  attribute :timezone do |object|
    object.time_zone
  end
end
