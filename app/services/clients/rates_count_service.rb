# frozen_string_literal: true

module Clients
  # Service class for getting and caching the number of rates of a client.
  class RatesCountService < Clients::CountService
    def cache_key_name
      'client_rates_count'
    end

    def self.query(client_ids)
      Rate::Client.where(owner_id: client_ids)
    end
  end
end
