class Converter::Quote
  def self.convert(quote, user)
    new(quote, user).convert
  end

  def initialize(quote, user)
    @quote = quote
    @user = user
  end

  def convert
    fulfill_conversion
  end

  private

  attr_reader :quote, :user

  PROJECT_ATTRIBUTES = %i(
    client_id
    owner_id
    workspace_id
    start_date
    due_date
  )

  TASK_ATTRIBUTES = %i(
    source_language_id
    target_language_id
    task_type_id
    unit_id
  )

  def fulfill_conversion
    ::Project.transaction do
      project = build_project
      project.tap(&:save!)
    end
  end

  def build_project
    permitted_attributes = quote.slice(PROJECT_ATTRIBUTES).tap do |hash|
      hash[:name] = compose_name
      hash[:owner] = user
      hash[:tasklists_attributes] = build_tasklists
    end

    ::Project.new(permitted_attributes)
  end

  def compose_name
    I18n.t(:'projects.name', date: Date.current.strftime('%d-%m-%Y'), number: 1)
  end

  def build_tasklists
    tasklists = []

    line_items.group_by { |i|
      [i.source_language, i.target_language]
    }.each do |language_combination, collection|
      unless collection.empty?
        tasklist = build_tasklist(language_combination, collection)
        tasklists.push(tasklist) if tasklist
      end
    end

    return tasklists
  end

  def line_items
    quote.
      line_items.
      includes(:source_language, :target_language, :task_type, :unit)
  end

  def build_tasklist(language_combination, collection)
    source_language = language_combination.first
    target_language = language_combination.last
    title = compose_tasklist_title(source_language, target_language)

    tasklist_params = {
      owner: user,
      tasks_attributes: build_tasks(collection),
      title: title
    }

    return tasklist_params
  end

  def compose_tasklist_title(source, target)
    if source && target
      I18n.t(
        :'language_combination',
        scope: :'tasklists.title',
        source: source.name,
        target: target.name,
        source_upcase: source.code.upcase,
        target_upcase: target.code.upcase
      )
    elsif !source && target
      I18n.t(
        :'target_language',
        scope: :'tasklists.title',
        target: target.name,
        target_upcase: target.code.upcase
      )
    else
      I18n.t(:'other', scope: :'tasklists.title')
    end
  end

  def build_tasks(collection)
    tasks = []

    collection.dup.each do |entry|
      task = build_task(entry)
      tasks.push(task) if task
    end

    return tasks
  end

  def build_task(entry)
    entry.slice(TASK_ATTRIBUTES).tap do |hash|
      hash[:owner] = user
      hash[:title] = entry.task_type.name
      hash[:unit_count] = entry.quantity
    end
  end
end
