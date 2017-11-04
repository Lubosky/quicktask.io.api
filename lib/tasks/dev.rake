namespace :dev do
  desc 'Creates sample data for local development'
  task :prime do
    unless Rails.env.development?
      raise 'This task can only be run in the development environment'
    end

    require 'factory_bot_rails'
    include FactoryBot::Syntax::Methods

    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke

    `bin/rails db:migrate RAILS_ENV=test`

    create_users
    create_plans
    create_workspaces
    create_memberships
  end

  def create_users
    header 'Users'

    user = create(
      :user,
      :confirmed_user,
      email: 'basic@example.dev'
    )
    puts_user user, 'basic user'

    user = create(
      :user,
      email: 'new@example.dev'
    )
    puts_user user, 'new user'

    user = create(
      :user,
      :with_google,
      email: 'whetstone@example.dev'
    )
    puts_user user, 'ready to auth against whetstone'

    user = create(
      :user,
      :with_google,
      :with_optional_password,
      email: 'google@example.dev'
    )
    puts_user user, 'with google auth'

    user = create(
      :user,
      :confirmed_user,
      email: 'confirmed@example.dev'
    )
    puts_user user, 'confirmed user'

    user = create(
      :user,
      :deactivated_user,
      email: 'deactivated@example.dev'
    )
    puts_user user, 'deactivated user'
  end

  def create_plans
    header 'Plans'

    Rake::Task['stripe:plan:sync'].invoke
  end

  def create_workspaces
    header 'Workspaces'

    workspace = create(
      :workspace,
      name: 'Pending Space',
      owner: User.find_by(email: 'basic@example.dev')
    )
    puts_workspace workspace, 'pending workspace'
  end

  def create_memberships
    header 'Memberships'

    workspace = create(
      :workspace,
      name: 'Subscribed Space',
      owner: User.find_by(email: 'google@example.dev')
    )

    membership = build(
      :membership,
      workspace: workspace,
      owner: workspace.owner,
      stripe_token: generate_stripe_token
    )

    membership.fulfill

    puts_membership membership
  end

  def generate_stripe_token
    Stripe::Token.create(
      card: {
        number: '4242424242424242',
        exp_month: Date.current.month.next,
        exp_year: Date.current.year.next,
        cvc: rand.to_s[2..4]
      }
    )
  end

  def header(msg)
    puts "\n\n*** #{msg.upcase} *** \n\n"
  end

  def puts_user(user, description)
    puts "#{user.email} / #{user.password} (#{description})"
  end

  def puts_workspace(workspace, description)
    puts "#{workspace.name} / #{workspace.slug} (#{description})"
  end

  def puts_membership(membership)
    puts "Membership for workspace: #{membership.workspace.name} / #{membership.workspace.slug}"
  end
end
