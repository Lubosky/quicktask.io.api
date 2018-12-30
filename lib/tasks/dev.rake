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

    Sidekiq::Queue.new.clear
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
    create_specializations
    create_task_types
    create_services
    create_units
    create_workspace_currencies
    create_clients
    create_client_contacts
    create_contractors
    create_workspace_accounts
    create_project_templates
    create_rates
    create_project_groups
    create_projects
    create_template_tasklists
    create_template_tasks
    create_tasklists
    create_tasks
    create_notes
    create_tags
    activate_projects
    create_todos
    create_hand_offs
    create_requests
    create_estimates
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
      :confirmed_user,
      email: 'client@example.dev'
    )
    puts_user user, 'to become a client'

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
      owner: User.find_by(email: 'basic@example.dev'),
      hand_off_valid_period: rand(1..96)
    )
    puts_workspace workspace, 'pending workspace'
  end

  def create_memberships
    header 'Memberships'

    workspace = create(
      :workspace,
      name: 'Subscribed Space',
      owner: User.find_by(email: 'google@example.dev'),
      hand_off_valid_period: rand(1..96)
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

      workspace.services.each do |service|
        service.task_types << workspace.task_types.with_type(service.classification).sample(3)
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

  def create_project_templates
    header 'Project Templates'

    puts "Creating project templates\u2026\n"
    print "\n"

    Workspace.active.find_each do |workspace|
      member = workspace.team_members.sample

      if member.present?
        ::ProjectTemplateBuilder.create_for(member.workspace_account, workspace)
      end

      3.times do
        print "\e[32m.\e[0m"

        create(
          :project_template,
          owner: member,
          workspace: workspace
        )
      end
    end

    print "\n"
    puts_project_template
  end

  def create_clients
    header 'Clients'

    puts "Creating clients\u2026\n"
    print "\n"

    Workspace.active.find_each do |workspace|
      20.times do
        print "\e[32m.\e[0m"

        create_client(workspace)
      end
    end

    print "\n"
    puts_client
  end

  def create_client(workspace)
    create(
      :client,
      workspace: workspace,
      name: Faker::Name.name,
      email: Faker::Internet.email,
      currency: :gbp
    )
  end

  def create_client_contacts
    header 'Client Contacts'

    puts "Creating client contacts\u2026\n"
    print "\n"

    Workspace.active.find_each do |workspace|
      workspace.clients.find_each do |client|

        3.times do
          print "\e[32m.\e[0m"

          create(
            :client_contact,
            client: client,
            workspace: workspace,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.email
          )
        end
      end
    end

    print "\n"
    puts_client_contact
  end

  def create_contractors
    header 'Contractors'

    puts "Creating contractors\u2026\n"
    print "\n"

    Workspace.active.find_each do |workspace|
      50.times do
        print "\e[32m.\e[0m"

        create_contractor(workspace)
      end
    end

    print "\n"
    puts_contractor
  end

  def create_contractor(workspace)
    contractor = create(
      :contractor,
      workspace: workspace,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email
    )
  end

  def create_notes
    header 'Notes'

    puts "Creating notes for projects\u2026\n"
    print "\n"

    Project::Regular.all.find_each do |project|
      5.times do
        workspace = project.workspace
        author = workspace.team_members.sample
        project.notes.create(author: author, content: Faker::Lorem.paragraph)

        print "\e[32m.\e[0m"
      end
    end

    print "\n"
    puts "Creating notes for tasks\u2026\n"
    print "\n"

    Task.all.find_each do |task|
      3.times do
        workspace = task.workspace
        author = workspace.team_members.sample
        task.notes.create(author: author, content: Faker::Lorem.paragraph)

        print "\e[32m.\e[0m"
      end
    end

    print "\n"
    puts_note
  end


  def create_project_groups
    header 'Project Groups'

    puts "Creating project groups\u2026\n"
    print "\n"

    Workspace.active.find_each do |workspace|
      workspace.clients.find_each do |client|
        print "\e[32m.\e[0m"

        create(
          :project_group,
          client: client,
          workspace: workspace
        )
      end
    end

    print "\n"
    puts_project_group
  end

  def create_projects
    header 'Projects'

    puts "Creating projects\u2026\n"
    print "\n"

    workspace = Workspace.active.first
    owner = workspace.team_members

    workspace.clients.find_each do |client|
      5.times do
        print "\e[32m.\e[0m"

        create(
          :project,
          client: client,
          owner: owner.sample,
          workspace: workspace
        )
      end
    end

    print "\n"
    puts_project
  end

  def activate_projects
    actions = ['prepare', 'plan', 'activate']

    Project::Regular.find_each do |project|
      project.send("#{actions.sample}!")
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

  def create_tags
    header 'Tags'
    puts "Creating tags\u2026\n"
    print "\n"

    Task.all.sample(300).each do |taggable|
      print "\e[32m.\e[0m"

      3.times do
        tag = Tag.find_or_create(
          color: Tag.colors.keys.sample,
          name: Faker::Team.mascot,
          workspace: taggable.workspace
        )

        taggable.tags << tag
      end
    end

    print "\n"
    puts_tag
  end

  def create_tasklists
    header 'Tasklists'

    Workspace.active.find_each do |workspace|
      workspace.projects.find_each do |project|
        9.times do
          create(
            :tasklist,
            owner: workspace&.team_members&.sample,
            project: project,
            workspace: workspace
          )
        end
      end

      puts_tasklist workspace
    end
  end

  def create_template_tasklists
    header 'Template tasklists'

    Workspace.active.find_each do |workspace|
      workspace.project_templates.except_system_templates.find_each do |template|
        3.times do
          create(
            :tasklist,
            owner: workspace&.team_members&.sample,
            project: template,
            workspace: workspace
          )
        end
      end

      puts_template_tasklist workspace
    end
  end

  def create_tasks
    header 'Tasks'
    puts "Creating tasks\u2026\n"
    print "\n"

    Tasklist.for_projects.includes(:project, :workspace).find_each do |tasklist|
      workspace = tasklist.workspace

      5.times do
        print "\e[32m.\e[0m"

        source_language = workspace.languages.sample
        target_language = workspace.languages.where.not(id: source_language.id).sample

        create(
          :task,
          tasklist: tasklist,
          owner: workspace.team_members.sample,
          project: tasklist.project,
          workspace: workspace,
          description: Faker::Lorem.paragraph,
          color: Task.colors.keys.sample,
          status: Task.statuses.keys.sample,
          source_language: source_language,
          target_language: target_language,
          task_type: workspace.task_types.sample,
          unit: workspace.units.sample
        )
      end
    end

    print "\n"
    puts_task
  end

  def create_template_tasks
    header 'Template tasks'
    puts "Creating template tasks\u2026\n"
    print "\n"

    Tasklist.for_project_templates.includes(:project, :workspace).find_each do |tasklist|
      next if tasklist&.project&.project_type == 'template' && tasklist&.project&.system_template?

      workspace = tasklist.workspace

      3.times do
        print "\e[32m.\e[0m"

        source_language = workspace.languages.sample
        target_language = workspace.languages.where.not(id: source_language.id).sample

        create(
          :task,
          tasklist: tasklist,
          owner: workspace.team_members.sample,
          project: tasklist.project,
          workspace: workspace,
          description: Faker::Lorem.paragraph,
          color: Task.colors.keys.sample,
          source_language: source_language,
          target_language: target_language,
          task_type: workspace.task_types.sample,
          unit: workspace.units.sample
        )
      end
    end

    print "\n"
    puts_template_task
  end

  def create_hand_offs
    header 'Hand-offs'
    puts "Creating hand-offs\u2026\n"
    print "\n"

    Task.includes(:workspace).find_each do |task|
      truthy = [true, false].sample
      workspace = task.workspace
      assignee_scope = task.other_task? ?
        workspace.team_members.sample :
        workspace.contractors.sample

      count = task.other_task? ? 1 : rand(1..3)

      count.times do
        print "\e[32m.\e[0m"

        create(
          :hand_off,
          assignee: assignee_scope,
          assigner: workspace.team_members.sample,
          task: task,
          workspace: workspace
        )

      rescue ActiveRecord::RecordInvalid => e
        nil
      end

      task.reload

      if truthy
        task&.hand_offs&.sample&.accept!
      end
    end

    print "\n"
    puts_hand_off
  end

  def create_task_types
    header 'Task Types'

    Workspace.find_each do |workspace|
      TaskType.create_for(workspace)

      create(
        :task_type,
        :other,
        workspace: workspace
      )

      puts_task_type workspace
    end
  end

  def create_todos
    header 'To-dos'
    puts "Creating to-dos\u2026\n"
    print "\n"

    Task.find_each do |task|
      n = rand(0..3)
      workspace = task.workspace

      n.times do
        print "\e[32m.\e[0m"

        create(
          :todo,
          completed: [true, false].sample,
          assignee: workspace.collaborating_team_members.sample,
          task: task,
          workspace: workspace
        )
      end
    end

    print "\n"
    puts_todo
  end

  def create_requests
    header 'Client requests'
    puts "Creating client requests\u2026\n"
    print "\n"

    workspaces = Workspace.active

    workspaces.each do |workspace|
      5.times do
        print "\e[32m.\e[0m"

        client = workspace.clients.sample
        client_contact = client.client_contacts.sample

        ClientRequest::Translation.create(
          workspace: workspace,
          client: client,
          requester: client_contact,
          service: workspace.services.with_type(:translation).first,
          source_language: workspace.languages.sample,
          target_language_ids: workspace.languages.sample(3),
          unit: workspace.units.sample,
          unit_count: rand(100..10000),
          start_date: Date.today + rand(7).days,
          due_date: Date.today + rand(10..90).days
        )
      end

      5.times do
        print "\e[32m.\e[0m"

        client = workspace.clients.sample
        client_contact = client.client_contacts.sample

        ClientRequest::Interpreting.create(
          workspace: workspace,
          client: client,
          requester: client_contact,
          service: workspace.services.with_type(:interpreting).first,
          source_language: workspace.languages.sample,
          target_language_ids: workspace.languages.sample(3),
          equipment_needed: [true, false].sample,
          interpreter_count: rand(10),
          start_date: Date.today + rand(7).days,
          due_date: Date.today + rand(10..90).days
        )
      end

      5.times do
        print "\e[32m.\e[0m"

        client = workspace.clients.sample
        client_contact = client.client_contacts.sample

        ClientRequest::Localization.create(
          workspace: workspace,
          client: client,
          requester: client_contact,
          service: workspace.services.with_type(:localization).first,
          target_language_ids: workspace.languages.sample(3),
          unit: workspace.units.sample,
          unit_count: rand(100..10000),
          start_date: Date.today + rand(7).days,
          due_date: Date.today + rand(10..90).days
        )
      end
    end

    print "\n"
    puts_client_requests
  end

  def create_estimates
    header 'Estimates'
    puts "Creating estimates\u2026\n"
    print "\n"

    Workspace.active.each do |workspace|
      requests = workspace.client_requests.sample(7)
      user = workspace.team_members.sample

      requests.each do |request|
        print "\e[32m.\e[0m"

        request.submit!
        request.convert(user)
        request.estimate!
      end
    end

    print "\n"
    puts_estimates
  end

  def create_workspace_currencies
    header 'Workspace Currencies'

    Workspace.find_each do |workspace|
      WorkspaceCurrency.create_for(workspace)

      puts_workspace_currency workspace
    end
  end

  def create_workspace_accounts
    header 'Workspace Accounts'

    Workspace.active.find_each do |workspace|
      team_member = create(
        :team_member,
        workspace: workspace,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      )

      workspace_account = create(
        :workspace_account,
        profile: team_member,
        role: workspace.roles.find_by(permission_level: :owner),
        workspace: workspace,
        user: workspace.owner
      )
      puts_workspace_account workspace_account

      contractor = create(
        :contractor,
        workspace: workspace,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      )

      workspace_account = create(
        :workspace_account,
        profile: contractor,
        role: workspace.roles.find_by(permission_level: :collaborator),
        workspace: workspace,
        user: User.find_by(email: 'contractor@example.dev')
      )
      puts_workspace_account workspace_account

      workspace.clients.find_each do |client|
        cc = client.client_contacts.sample

        workspace_account = create(
          :workspace_account,
          profile: cc,
          role: workspace.roles.find_by(permission_level: :client),
          workspace: workspace,
          user: create(:user, :confirmed_user, first_name: cc.first_name, last_name: cc.first_name, email: cc.email)
        )
        puts_workspace_account workspace_account
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

  def puts_client
    puts "\e[32mClients created! ^_^\e[0m"
  end

  def puts_client_contact
    puts "\e[32mClient contacts created! ^_^\e[0m"
  end

  def puts_client_rate(workspace)
    puts "Client rates for workspace: #{workspace.name}"
  end

  def puts_client_requests
    puts "\e[32mClient requests created! ^_^\e[0m"
  end

  def puts_contractor
    puts "\e[32mContractors created! ^_^\e[0m"
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

  def puts_estimates
    puts "\e[32mEstimates created! ^_^\e[0m"
  end

  def puts_hand_off
    puts "\e[32mHand-offs created! ^_^\e[0m"
  end

  def puts_language(workspace)
    puts "Languages for workspace: #{workspace.name}"
  end

  def puts_membership(membership)
    puts "Membership for workspace: #{membership.workspace.name}"
  end

  def puts_note
    puts "\e[32mNotes created! ^_^\e[0m"
  end

  def puts_project_group
    puts "\e[32mProject groups created! ^_^\e[0m"
  end

  def puts_project_template
    puts "\e[32mProject templatess created! ^_^\e[0m"
  end

  def puts_project
    puts "\e[32mProjects created! ^_^\e[0m"
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

  def puts_tag
    puts "\e[32mTags created! ^_^\e[0m"
  end

  def puts_task
    puts "\e[32mTasks created! ^_^\e[0m"
  end

  def puts_template_task
    puts "\e[32mTemplate tasks created! ^_^\e[0m"
  end

  def puts_tasklist(workspace)
    puts "Tasklists for workspace: #{workspace.name}"
  end

  def puts_template_tasklist(workspace)
    puts "Template tasklists for workspace: #{workspace.name}"
  end

  def puts_task_type(workspace)
    puts "Task types for workspace: #{workspace.name}"
  end

  def puts_todo
    puts "\e[32mTo-dos created! ^_^\e[0m"
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

  def puts_workspace_account(workspace_account)
    puts "Workspace account w/ role #{workspace_account.role.name} in workspace: #{workspace_account.workspace.name}"
  end
end
