FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :google_uid do |n|
    "google_uid_#{n}"
  end

  sequence :name do |n|
    "name_#{n}"
  end

  sequence :uuid do |n|
    "uuid_#{n}"
  end

  factory :client do
    uuid
    name
    currency :usd
    association :workspace, factory: :workspace
  end

  factory :client_contact do
    uuid
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email
    association :client, factory: :client
    association :workspace, factory: :workspace
  end

  factory :contractor do
    uuid
    email
    currency :usd
    association :workspace, factory: :workspace
  end

  factory :membership, aliases: [:active_membership] do
    uuid
    quantity 1
    status :trialing
    association :owner, factory: :user
    association :workspace
    plan { Plan.first || create(:plan) }

    factory :inactive_membership do
      deactivated_on { Time.zone.today }
      status :deactivated

      factory :paused_membership_restarting_today do
        scheduled_for_reactivation_on { Time.zone.today }
      end

      factory :paused_membership_restarting_tomorrow do
        scheduled_for_reactivation_on { Time.zone.tomorrow }
      end
    end
  end

  factory :charge do
    uuid
    association :workspace
  end

  factory :plan do
    uuid
    name 'Airborne Bucket [M]'
    stripe_plan_id 'tms.GliderPath.AirborneBucket.Monthly'
    price 29.99
    range 1..5
    billing_interval 'month'
    trial_period_days 14

    trait :with_range_up_to_15 do
      name 'Soaring Bucket [M]'
      stripe_plan_id 'tms.GliderPath.SoaringBucket.Monthly'
      price 26.99
      range 6..15
      billing_interval 'month'
    end

    trait :with_range_up_to_100 do
      name 'Cruising Bucket [M]'
      stripe_plan_id 'tms.GliderPath.CruisingBucket.Monthly'
      price 23.99
      range 16..100
      billing_interval 'month'
    end

    trait :annual do
      name 'Airborne Bucket [A]'
      stripe_plan_id 'tms.GliderPath.AirborneBucket.Annually'
      price 299.00
      range 1..5
      billing_interval 'year'
    end

    trait :annual_with_range_up_to_15 do
      name 'Soaring Bucket [A]'
      stripe_plan_id 'tms.GliderPath.SoaringBucket.Annually'
      price 269.00
      range 6..15
      billing_interval 'year'
    end

    trait :annual_with_range_up_to_100 do
      name 'Cruising Bucket [A]'
      stripe_plan_id 'tms.GliderPath.CruisingBucket.Annually'
      price 239.00
      range 16..100
      billing_interval 'year'
    end
  end

  factory :project_group do
    uuid
    name
    association :client
    association :workspace
  end

  factory :project do
    uuid
    name
    association :client
    association :owner, factory: :workspace_user
    association :workspace
  end

  factory :role, class: Role::Base do
    uuid
    name
    permission_level :member
    association :workspace

    factory :client_role, class: Role::Client
    factory :collaborator_role, class: Role::Collaborator
    factory :owner_role, class: Role::Owner
  end

  factory :team_member do
    uuid
    email
    association :workspace, factory: :workspace
  end

  factory :token do
    association :user, factory: :user
    issued_at Time.current
    expiry_date Time.current + 12.hours
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

  factory :workspace do
    uuid
    name
    currency :usd
    association :owner, factory: :user

    trait :with_inactive_membership do
      status :deactivated
      stripe_customer_id "customer123"

      after :create do |instance|
        create(:inactive_membership, workspace: instance)
      end
    end

    trait :with_membership do
      status :active

      transient do
        plan { create(:plan) }
      end

      after :create do |instance, attributes|
        create(
          :membership,
          workspace: instance,
          plan: attributes.plan,
          owner: instance.owner
        )
      end
    end

    trait :with_roles do
      after :create do |instance|
        Role::Base.create_for(instance)
      end
    end
  end

  factory :workspace_currency do
    uuid
    code :jpy
    association :workspace, factory: :workspace
  end

  factory :workspace_user do
    uuid
    association :member, factory: :team_member
    association :role, factory: :role
    association :workspace, factory: :workspace
    association :user, factory: :user

    trait :with_client do
      association :member, factory: :client
    end

    trait :with_collaborator do
      association :member, factory: :collaborator
    end
  end
end
