# frozen_string_literal: true

module Clients
  # Base class for the various service classes that count client data (e.g.
  # projects or tasks).
  class CountService < BaseCountService
    # The version of the cache format. This should be bumped whenever the
    # underlying logic changes. This removes the need for explicitly flushing
    # all caches.
    VERSION = 1

    def initialize(client)
      @client = client
    end

    def relation_for_count
      self.class.query(@client.id)
    end

    def cache_key_name
      raise(
        NotImplementedError,
        '"cache_key_name" must be implemented and return a String'
      )
    end

    def cache_key(key = nil)
      cache_key = key || cache_key_name

      "clients/count_service/#{VERSION}/#{@client.id}/#{cache_key}"
    end

    def self.query(client_ids)
      raise(
        NotImplementedError,
        '"query" must be implemented and return an ActiveRecord::Relation'
      )
    end
  end
end
