class PotentialAssigneesQuery
  attr_reader :query, :task

  def self.build_query(task)
    association_fields = association_fields(task)
    query_builder = new(task)
    association_fields.inject(query_builder) { |query_builder, method| query_builder.send(method) }.query
  end

  def initialize(task, query = nil)
    @task = task
    @query = query || base_query
  end

  def base_query
    Contractor.select(contractors[:id]).joins(join_query)
  end

  def join_query
    contractors
      .join(rates)
      .on(contractors[:id].eq(rates[:owner_id]))
      .join_sources
  end

  def contractors
    Contractor.arel_table
  end

  def rates
    Rate::Contractor.arel_table
  end


  def source_language_id
    reflect(query.where(rates[:source_language_id].eq(task.source_language_id)))
  end

  def target_language_id
    reflect(query.where(rates[:target_language_id].eq(task.target_language_id)))
  end

  def task_type_id
    reflect(query.where(rates[:task_type_id].eq(task.task_type_id)))
  end

  def unit_id
    reflect(query.where(rates[:unit_id].eq(task.unit_id)))
  end

  def location
    reflect(query.where(contractors[:location].eq(task.location)))
  end

  def reflect(query)
    self.class.new(task, query)
  end

  def self.association_fields(task)
    task.attributes.keys & Task::TASK_FIELDS.with_indifferent_access[task.classification]
  end
end
