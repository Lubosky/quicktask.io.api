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

  sequence :title do |n|
    "title_#{n}"
  end

  sequence :uuid do |n|
    "uuid_#{n}"
  end

  factory :client do
    uuid
    name
    currency :usd
    workspace
  end

  factory :client_contact do
    uuid
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email
    association :client, factory: :client
    association :workspace, factory: :workspace
  end

  factory :client_request, class: ClientRequest::Other do
    uuid
    subject Faker::Job.title
    start_date DateTime.current
    due_date DateTime.current + 5.hours
    unit_count 10

    workspace
    client
    association :owner, factory: [:workspace_user, :with_client]
    association :service, factory: [:service]
    unit

    factory :interpreting_request, class: ClientRequest::Interpreting
    factory :localization_request, class: ClientRequest::Localization
    factory :translation_request, class: ClientRequest::Translation
  end

  factory :contractor do
    uuid
    email
    currency :usd
    association :workspace, factory: :workspace
  end

  factory :hand_off do
    uuid
    rate_applied Random.rand(0.99...99.99)

    association :assignee, factory: :contractor
    association :assigner, factory: :team_member
    association :task, factory: :task
    association :workspace, factory: :workspace

    trait :accepted do
      accepted_at DateTime.current
    end

    trait :rejected do
      rejected_at DateTime.current
    end

    trait :expired do
      expired_at DateTime.current
    end

    trait :cancelled do
      cancelled_at DateTime.current
      association :canceller, factory: :team_member
    end
  end

  factory :language, aliases: [:source_language, :target_language] do
    uuid
    code :en
    name
    association :workspace, factory: :workspace
  end

  factory :line_item do
    uuid
    quantity 10
    unit_price 10

    workspace
    association :bookkeepable, factory: :quote
    association :source_language, factory: [:language, code: :en]
    association :target_language, factory: [:language, code: :de]
    task_type
    unit
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
    association :owner, factory: :team_member
    association :workspace
  end

  factory :quote do
    uuid
    subject Faker::Job.title
    status :draft
    issue_date DateTime.current
    expiry_date DateTime.current + 7.days
    start_date DateTime.current
    due_date DateTime.current + 1.days

    association :workspace, factory: :workspace
    association :client, factory: :client
    association :owner, factory: :team_member

    trait :with_discount do
      discount 10
    end

    trait :with_surcharge do
      surcharge 10
    end
  end

  factory :role, class: Role::Base do
    uuid
    name
    permission_level :member
    association :workspace, factory: :workspace

    factory :client_role, class: Role::Client
    factory :collaborator_role, class: Role::Collaborator
    factory :owner_role, class: Role::Owner
  end

  factory :service do
    uuid
    classification :translation
    name
    association :workspace, factory: :workspace
  end

  factory :specialization do
    uuid
    name
    association :workspace, factory: :workspace

    trait :default do
      default true
    end
  end

  factory :tasklist do
    uuid
    title

    association :owner, factory: :team_member
    association :project, factory: :project
    association :workspace, factory: :workspace
  end

  factory :task do
    uuid
    title

    color :no_color

    start_date DateTime.current
    due_date DateTime.current + 1.day

    association :owner, factory: :team_member
    association :tasklist, factory: :tasklist
    association :project, factory: :project
    association :workspace, factory: :workspace
    association :source_language, code: :en
    association :target_language, code: :de
    association :task_type, factory: :task_type
    association :unit, factory: :unit
  end

  factory :task_type do
    uuid
    name
    classification :translation
    workspace

    trait :billable do
      billable true
    end

    trait :internal do
      internal true
    end

    trait :preferred do
      preferred true
    end

    trait :interpreting do
      classification :interpreting
    end

    trait :localization do
      classification :localization
    end

    trait :other do
      classification :other
    end
  end

  factory :team_member do
    uuid
    email
    association :workspace, factory: :workspace
  end

  factory :todo do
    uuid
    title

    due_date DateTime.current + 1.day

    association :task, factory: :task
    association :workspace, factory: :workspace

    trait :completed do
      completed true
    end

    trait :with_assignee do
      association :assignee, factory: :workspace_user
    end
  end

  factory :token do
    association :user, factory: :user
    issued_at Time.current
    expiry_date Time.current + 12.hours
  end

  factory :unit do
    uuid
    name
    association :workspace, factory: :workspace
  end

  factory :user do
    uuid
    email
    password 'p@ssword'
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

    trait :with_google do
      google_uid
      password 'p@ssword'
      password_automatically_set true
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

    trait :with_currencies do
      after :create do |instance|
        WorkspaceCurrency.create_for(instance)
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
      association :member, factory: :client_contact
    end

    trait :with_collaborator do
      association :member, factory: :collaborator
    end
  end
end
