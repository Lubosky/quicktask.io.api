# frozen_string_literal: true

module Workspaces
  # Service class for getting and caching the number of contractors of a workspace.
  class ContractorsCountService < Workspaces::CountService
    def cache_key_name
      'contractors_count'
    end

    def self.query(workspace_ids)
      Contractor.where(workspace_id: workspace_ids)
    end
  end
end
