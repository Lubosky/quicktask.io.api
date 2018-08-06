namespace :dev do
  desc 'Creates sample data for local development'
  task :prime do
    unless Rails.env.development?
      raise 'This task can only be run in the development environment'
    end

    ActionMailer::Base.delivery_method = :test

    require 'factory_bot_rails'
    require 'sidekiq/api'

    include FactoryBot::Syntax::Methods

    Sidekiq::Queue.all do |queue|
      queue.clear
    end

    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::DeadSet.new.clear
    Sidekiq::Stats.new.reset

    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke

    `bin/rails db:migrate RAILS_ENV=test`

    create_users
    create_plans
    create_workspaces
    create_memberships
    create_roles
    create_languages
    create_services
    create_specializations
    create_task_types
    create_units
    create_workspace_currencies
    create_clients
    create_client_contacts
    create_workspace_users
    create_rates
    create_project_groups
    create_projects
    create_tasklists
    create_tasks
    create_todos
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
      email: 'contractor@example.dev'
    )
    puts_user user, 'to become a contractor'

    user = create(
      :user,
      :with_google,
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

    workspace = create(
      :workspace,
      name: 'Awesome Space',
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

  def create_roles
    header 'Roles'

    Workspace.find_each do |workspace|
      Role::Base.create_for(workspace)

      puts_role workspace
    end
  end

  def create_languages
    header 'Languages'

    Workspace.find_each do |workspace|
      Language.create_for(workspace)

      puts_language workspace
    end
  end

  def create_units
    header 'Units'

    Workspace.find_each do |workspace|
      Unit.create_for(workspace)

      puts_unit workspace
    end
  end

  def create_services
    header 'Services'

    Workspace.find_each do |workspace|
      [:translation, :interpreting, :localization, :other].each do |type|
        create(
          :service,
          workspace: workspace,
          classification: type.to_sym,
          name: type.to_s.capitalize
        )
      end

      puts_service workspace
    end
  end

  def create_specializations
    header 'Specializations'

    Workspace.find_each do |workspace|
      Specialization.create_for(workspace)

      puts_specialization workspace
    end
  end

  def create_clients
    header 'Clients'

    Workspace.active.find_each do |workspace|
      client = create(
        :client,
        workspace: workspace,
        name: Faker::Name.name,
        email: Faker::Internet.email,
        currency: :usd
      )
      puts_client client

      client = create(
        :client,
        workspace: workspace,
        name: Faker::Name.name,
        email: Faker::Internet.email,
        currency: :gbp
      )
      puts_client client

      client = create(
        :client,
        workspace: workspace,
        name: Faker::Name.name,
        email: Faker::Internet.email,
        currency: :eur
      )
      puts_client client
    end
  end

  def create_client_contacts
    header 'Client Contacts'

    Workspace.active.find_each do |workspace|
      workspace.clients.find_each do |client|
        client_contact = create(
          :client_contact,
          client: client,
          workspace: workspace,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email
        )
        puts_client_contact client_contact

        client_contact = create(
          :client_contact,
          client: client,
          workspace: workspace,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email
        )
        puts_client_contact client_contact

        client_contact = create(
          :client_contact,
          client: client,
          workspace: workspace,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email
        )
        puts_client_contact client_contact
      end
    end
  end

  def create_project_groups
    header 'Project Groups'

    Workspace.active.find_each do |workspace|
      workspace.clients.find_each do |client|
        project_group = create(
          :project_group,
          client: client,
          workspace: workspace
        )
        puts_project_group(project_group, workspace)
      end
    end
  end

  def create_projects
    header 'Projects'

    workspace = Workspace.active.first
    owner = WorkspaceUser.where(member_type: 'TeamMember', workspace: workspace).first

    workspace.clients.find_each do |client|
      project = create(
        :project,
        client: client,
        owner: owner,
        workspace: workspace
      )
      puts_project(project, workspace)

      project = create(
        :project,
        client: client,
        owner: owner,
        workspace: workspace
      )
      puts_project(project, workspace)

      project = create(
        :project,
        client: client,
        owner: owner,
        workspace: workspace
      )
      puts_project(project, workspace)
    end
  end

  def create_rates
    header 'Rates'

    Workspace.active.find_each do |workspace|
      # DEFAULT CLIENT RATES
      100.times do
        source_language = workspace.languages.sample
        target_language = workspace.languages.where.not(id: source_language.id).sample

        rate = workspace.default_client_rates.build(
          task_type: workspace.task_types.sample,
          source_language: source_language,
          target_language: target_language,
          unit: workspace.units.sample,
          price: rand(100),
          workspace: workspace
        )

        rate.save!
      end

      puts_default_client_rate workspace

      # DEFAULT CONTRACTOR RATES
      100.times do
        source_language = workspace.languages.sample
        target_language = workspace.languages.where.not(id: source_language.id).sample

        rate = workspace.default_contractor_rates.build(
          task_type: workspace.task_types.sample,
          source_language: source_language,
          target_language: target_language,
          unit: workspace.units.sample,
          price: rand(100),
          workspace: workspace
        )

        rate.save!
      end

      puts_default_contractor_rate workspace

      # CONTRACTOR RATES
      workspace.contractors.each do |contractor|
        100.times do
          source_language = workspace.languages.sample
          target_language = workspace.languages.where.not(id: source_language.id).sample

          rate = contractor.contractor_rates.build(
            task_type: workspace.task_types.sample,
            source_language: source_language,
            target_language: target_language,
            unit: workspace.units.sample,
            price: rand(100),
            workspace: workspace
          )

          rate.save!
        end
      end

      puts_contractor_rate workspace

      # CLIENT RATES
      workspace.clients.each do |client|
        100.times do
          source_language = workspace.languages.sample
          target_language = workspace.languages.where.not(id: source_language.id).sample

          rate = client.client_rates.build(
            task_type: workspace.task_types.sample,
            source_language: source_language,
            target_language: target_language,
            unit: workspace.units.sample,
            price: rand(100),
            workspace: workspace
          )

          rate.save!
        end
      end

      puts_client_rate workspace
    end
  end

  def create_tasklists
    header 'Tasklists'

    Workspace.active.find_each do |workspace|
      workspace.projects.find_each do |project|
        9.times do
          create(
            :tasklist,
            owner: workspace.collaborating_team_members.sample,
            project: project,
            workspace: workspace
          )
        end
      end

      puts_tasklist workspace
    end
  end

  def create_tasks
    header 'Tasks'

    Tasklist.includes(:project, :workspace).find_each do |tasklist|
      workspace = tasklist.workspace

      15.times do
        source_language = workspace.languages.sample
        target_language = workspace.languages.where.not(id: source_language.id).sample

        create(
          :task,
          tasklist: tasklist,
          owner: workspace.collaborating_team_members.sample,
          project: tasklist.project,
          workspace: workspace,
          color: Task.colors.keys.sample,
          status: Task.statuses.keys.sample,
          source_language: source_language,
          target_language: target_language,
          task_type: workspace.task_types.sample,
          unit: workspace.units.sample
        )
      end

      puts_task tasklist
    end
  end

  def create_task_types
    header 'Task Types'

    Workspace.find_each do |workspace|
      TaskType.create_for(workspace)

      puts_task_type workspace
    end
  end

  def create_todos
    header 'To-dos'

    Task.find_each do |task|
      n = rand(0..3)
      workspace = task.workspace

      n.times do
        create(
          :todo,
          completed: [true, false].sample,
          assignee: workspace.collaborating_team_members.sample,
          task: task,
          workspace: workspace
        )
      end
    end

    puts_todo
  end

  def create_workspace_currencies
    header 'Workspace Currencies'

    Workspace.find_each do |workspace|
      WorkspaceCurrency.create_for(workspace)

      puts_workspace_currency workspace
    end
  end

  def create_workspace_users
    header 'Workspace Users'

    Workspace.active.find_each do |workspace|
      team_member = create(
        :team_member,
        workspace: workspace,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      )

      workspace_user = create(
        :workspace_user,
        member: team_member,
        role: workspace.roles.find_by(permission_level: :owner),
        workspace: workspace,
        user: workspace.owner
      )
      puts_workspace_user workspace_user

      contractor = create(
        :contractor,
        workspace: workspace,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      )

      workspace_user = create(
        :workspace_user,
        member: contractor,
        role: workspace.roles.find_by(permission_level: :collaborator),
        workspace: workspace,
        user: User.find_by(email: 'contractor@example.dev')
      )
      puts_workspace_user workspace_user

      workspace.clients.find_each do |client|
        cc = client.client_contacts.first

        workspace_user = create(
          :workspace_user,
          member: cc,
          role: workspace.roles.find_by(permission_level: :client),
          workspace: workspace,
          user: create(:user, :confirmed_user, first_name: cc.first_name, last_name: cc.first_name, email: cc.email)
        )
        puts_workspace_user workspace_user
      end
    end
  end

  def generate_stripe_token
    Stripe::Token.create(
      card: {
        number: '4242424242424242',
        exp_month: Date.current.next_month.month,
        exp_year: Date.current.year.next,
        cvc: rand.to_s[2..4]
      }
    )
  end

  def header(msg)
    puts "\n\n*** #{msg.upcase} *** \n\n"
  end

  def puts_client(client)
    puts "Client #{client.name} / #{client.email} in workspace: #{client.workspace.name}"
  end

  def puts_client_contact(client_contact)
    puts "Contact #{client_contact.first_name} #{client_contact.last_name} / #{client_contact.email} for client #{client_contact.client.name} in workspace: #{client_contact.workspace.name}"
  end

  def puts_client_rate(workspace)
    puts "Client rates for workspace: #{workspace.name}"
  end

  def puts_contractor_rate(workspace)
    puts "Contractor rates for workspace: #{workspace.name}"
  end

  def puts_default_client_rate(workspace)
    puts "Default client rates for workspace: #{workspace.name}"
  end

  def puts_default_contractor_rate(workspace)
    puts "Default contractor rates for workspace: #{workspace.name}"
  end

  def puts_language(workspace)
    puts "Languages for workspace: #{workspace.name}"
  end

  def puts_membership(membership)
    puts "Membership for workspace: #{membership.workspace.name}"
  end

  def puts_project_group(project_group, workspace)
    puts "Project group #{project_group.name} in workspace: #{workspace.name}"
  end

  def puts_project(project, workspace)
    puts "Project #{project.name} in workspace: #{workspace.name}"
  end

  def puts_role(workspace)
    puts "Roles for workspace: #{workspace.name}"
  end

  def puts_service(workspace)
    puts "Services for workspace: #{workspace.name}"
  end

  def puts_specialization(workspace)
    puts "Specializations for workspace: #{workspace.name}"
  end

  def puts_task(tasklist)
    puts "Tasks for tasklist: #{tasklist.title} / #{tasklist.workspace.name}"
  end

  def puts_tasklist(workspace)
    puts "Tasklists for workspace: #{workspace.name}"
  end

  def puts_task_type(workspace)
    puts "Task types for workspace: #{workspace.name}"
  end

  def puts_todo
    puts "To-dos created"
  end

  def puts_unit(workspace)
    puts "Units for workspace: #{workspace.name}"
  end

  def puts_user(user, description)
    puts "#{user.email} / #{user.password} (#{description})"
  end

  def puts_workspace(workspace, description)
    puts "#{workspace.name} (#{description})"
  end

  def puts_workspace_currency(workspace)
    puts "Currencies for workspace: #{workspace.name}"
  end

  def puts_workspace_user(workspace_user)
    puts "Workspace user w/ role #{workspace_user.role.name} in workspace: #{workspace_user.workspace.name}"
  end
end
