# frozen_string_literal: true

module Dashboard
  class TaskMeta
    DUE_DATE_AGGREGATIONS = %w(task owner assignee)
    OTHER_AGGREGATIONS = %w(assignee_id status completed_status)

    attr_accessor :results, :meta

    def initialize(results)
      @results = results
      @meta = Hash.new(0)
    end

    def call
      get_total_count
      get_page_meta
      get_due_date_aggregations
      get_other_aggregations

      return meta
    end

    private

    def get_total_count
      meta[h_key(:total_count)] = results.total_count
    end

    def get_page_meta
      [:next_page, :previous_page].each do |param|
        meta[h_key(param)] = results.send(param.to_s)
      end
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

          meta[h_key(param)] = data
        end
      end
    end

    def aggregations
      results.aggregations
    end

    def get_total_count_for(param)
      value = aggregations.dig(param, 'doc_count')

      meta[h_key(param)] = { count: value }
    end

    def count_by_due_date(param)
      chart_data = {}
      params = aggregations.dig(param, 'due_date_count', 'buckets')

      params.each_with_object({}) do |h|
        key = h['key']
        value = h['doc_count']

        chart_data[h_key(key)] = value
      end

      meta[h_key(param)].merge!({ chart: chart_data })
    end

    def h_key(value)
      key = Array(value).last
      key.respond_to?(:to_sym) ? key.to_sym : key.to_s
    end
  end
end
