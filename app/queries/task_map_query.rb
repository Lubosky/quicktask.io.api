class TaskMapQuery
  def self.query
    new().base_query
  end

  def base_query
    Arel.sql <<~SQL
      (SELECT array_agg(task_array) FROM (#{tasklist_query}) AS collection_array) AS collection_map
    SQL
  end

  private

  def projects
    Project.arel_table
  end

  def tasklists
    Tasklist.arel_table
  end

  def tasks
    Task.arel_table
  end

  def build_object_fn
    Arel::Nodes::NamedFunction.new('json_build_object', [
      tasklists[:id],
      Arel::Nodes::NamedFunction.new('COALESCE', [
        Arel.sql("array_agg(collection.id::TEXT) FILTER (WHERE NOT (collection.id IS NULL))"),
        Arel.sql("ARRAY[]::text[]")
      ])
    ]).as('task_array')
  end

  def join_query
    tasks.
      project(tasks[:id]).
        where(tasks[:tasklist_id].eq(tasklists[:id]).and(tasks[:deleted_at].eq(nil))).
        order(tasks[:position]).to_sql
  end

  def tasklist_query
    tasklists.
      project(build_object_fn).
        join(Arel.sql("LEFT JOIN LATERAL (#{join_query}) AS collection ON TRUE")).
        where(tasklists[:project_id].eq(projects[:id]).and(tasklists[:deleted_at].eq(nil))).
        group(tasklists[:id]).
        order(tasklists[:position]).to_sql
  end
end
