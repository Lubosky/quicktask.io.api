# frozen_string_literal: true

module Workspaces
  # Service class for getting and caching the number of tasks of a workspace.
  class TasksCountService < Workspaces::CountService
    def cache_key_name
      'tasks_count'
    end

    def self.query(workspace_ids)
      Task.where(workspace_id: workspace_ids)
    end
  end
end
