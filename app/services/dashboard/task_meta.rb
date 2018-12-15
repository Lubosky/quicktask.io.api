# frozen_string_literal: true

module Dashboard
  class TaskMeta
    DUE_DATE_AGGREGATIONS = %w(task owner assignee)
    OTHER_AGGREGATIONS = %w(assignee_id status completed_status)
    PAGE_META = %w(current_page next_page previous_page total_pages offset_value)

    attr_accessor :results, :meta, :stats

    def initialize(results, transform_keys = false)
      @results = results
      @transform_keys = transform_keys
      @meta = Hash.new(0)
      @stats = Hash.new(0)
    end

    def call
      get_total_count
      get_page_meta
      get_stats
      run_key_transform if @transform_keys

      return meta
    end

    private

    def run_key_transform
      meta.deep_transform_keys! { |k| k.to_s.camelize(:lower) }
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
      get_due_date_aggregations
      get_other_aggregations

      meta[h_key(:stats)] = stats
    end

    def get_due_date_aggregations
      DUE_DATE_AGGREGATIONS.each_with_object({}) do |param|
        get_total_count_for(param)
        count_by_due_date(param)
      end
    end

    def get_other_aggregations
      OTHER_AGGREGATIONS.each_with_object({}) do |param|
        buckets = aggregations.dig(param, param, 'buckets')

        unless buckets.empty?
          data = {}
          buckets.each_with_object({}) do |h|
            key = h['key']
            value = h['doc_count']

            data[h_key(key)] = value
          end

          stats[h_key(param)] = data
        end
      end
    end

    def aggregations
      results.aggregations
    end

    def get_total_count_for(param)
      value = aggregations.dig(param, 'doc_count')

      stats[h_key(param)] = { count: value }
    end

    def count_by_due_date(param)
      aggs_data = {}
      params = aggregations.dig(param, 'due_date_count', 'buckets')

      params.each_with_object({}) do |h|
        key = h['key']
        value = h['doc_count']

        aggs_data[h_key(key)] = value
      end

      stats[h_key(param)].merge!({ aggs: aggs_data })
    end

    def h_key(value)
      key = Array(value).last
      key.respond_to?(:to_sym) ? key.to_sym : key.to_s
    end
  end
end
