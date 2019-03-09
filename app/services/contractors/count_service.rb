# frozen_string_literal: true

module Contractors
  # Base class for the various service classes that count contractor data (e.g.
  # projects or tasks).
  class CountService < BaseCountService
    # The version of the cache format. This should be bumped whenever the
    # underlying logic changes. This removes the need for explicitly flushing
    # all caches.
    VERSION = 1

    def initialize(contractors)
      @contractors = contractors
    end

    def relation_for_count
      self.class.query(@contractors.id)
    end

    def cache_key_name
      raise(
        NotImplementedError,
        '"cache_key_name" must be implemented and return a String'
      )
    end

    def cache_key(key = nil)
      cache_key = key || cache_key_name

      "contractorss/count_service/#{VERSION}/#{@contractors.id}/#{cache_key}"
    end

    def self.query(contractor_ids)
      raise(
        NotImplementedError,
        '"query" must be implemented and return an ActiveRecord::Relation'
      )
    end
  end
end
