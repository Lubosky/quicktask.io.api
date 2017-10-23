FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :google_uid do |n|
    "google_uid_#{n}"
  end

  sequence :uuid do |n|
    "uuid_#{n}"
  end

  factory :user do
    uuid
    email
    password 'p@ssword'
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

    trait :with_optional_password do
      google_uid
      password nil
      password_digest ''
    end

    trait :with_google do
      google_uid
    end

    trait :confirmed_user do
      email_confirmed true
    end

    trait :deactivated_user do
      deactivated_at Time.current
    end
  end

  factory :token do
    association :user, factory: :user
    issued_at Time.current
    expiry_date Time.current + 12.hours
  end
end
