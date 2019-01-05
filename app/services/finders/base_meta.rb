# frozen_string_literal: true

module Finders
  class BaseMeta
    PAGE_META = %w(current_page next_page previous_page total_pages offset_value)

    attr_accessor :results, :meta, :stats

    def initialize(results, transform_keys = false)
      @results = results
      @transform_keys = transform_keys
      @meta = Hash.new()
      @stats = Hash.new()
    end

    def call
      get_total_count
      get_page_meta
      get_stats
      run_key_transform if @transform_keys

      return meta
    end

    private

    def aggregations
      results.aggregations
    end

    def get_total_count
      meta[h_key(:total_count)] = results.total_count
    end

    def get_page_meta
      PAGE_META.each do |param|
        meta[h_key(param)] = results.send(param.to_s)
      end
    end

    def get_stats
      raise NotImplementedError.new
    end

    def run_key_transform
      meta.deep_transform_keys! { |k| k.to_s.camelize(:lower) }
    end

    def h_key(value)
      key = Array(value).last
      key.respond_to?(:to_sym) ? key.to_sym : key.to_s
    end
  end
end
