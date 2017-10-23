namespace :dev do
  desc 'Creates sample data for local development'
  task prime: ['db:setup'] do
    unless Rails.env.development?
      raise 'This task can only be run in the development environment'
    end

    require 'factory_bot_rails'
    include FactoryBot::Syntax::Methods

    create_users
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

  def header(msg)
    puts "\n\n*** #{msg.upcase} *** \n\n"
  end

  def puts_user(user, description)
    puts "#{user.email} / #{user.password} (#{description})"
  end
end
