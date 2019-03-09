# frozen_string_literal: true

module Contractors
  # Service class for getting and caching the number of rates of a contractor.
  class RatesCountService < Contractors::CountService
    def cache_key_name
      'contractor_rates_count'
    end

    def self.query(contractor_ids)
      Rate::Contractor.where(owner_id: contractor_ids)
    end
  end
end
