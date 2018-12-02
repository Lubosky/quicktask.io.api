# frozen_string_literal: true

module Workspaces
  # Service class for getting and caching the number of clients of a workspace.
  class ClientsCountService < Workspaces::CountService
    def cache_key_name
      'clients_count'
    end

    def self.query(workspace_ids)
      Client.where(workspace_id: workspace_ids)
    end
  end
end
