# frozen_string_literal: true

module Workspaces
  # Service class for getting and caching the number of projects of a workspace.
  class ProjectsCountService < Workspaces::CountService
    def cache_key_name
      'projects_count'
    end

    def self.query(workspace_ids)
      Project::Regular.where(workspace_id: workspace_ids)
    end
  end
end
