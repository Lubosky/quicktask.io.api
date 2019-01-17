# frozen_string_literal: true

module Finders
  class TaskMeta < Finders::BaseMeta
    DATE_AGGREGATIONS = %w(due_date completed_date)
    STATUS_AGGREGATIONS = %w(status completed_status)
    OTHER_AGGREGATIONS = %w(assignees owners projects)

    private

    def get_stats
      get_date_aggregations
      get_status_aggregations
      get_other_aggregations

      meta[h_key(:stats)] = stats
    end

    def get_date_aggregations
      DATE_AGGREGATIONS.each_with_object({}) do |param|
        get_total_count_for(param)
        count_by_date(param)
      end
    end

    def get_status_aggregations
      STATUS_AGGREGATIONS.each_with_object({}) do |param|
        buckets = aggregations.dig(param, param, 'buckets')

        unless buckets.empty?
          if param == 'status'
            data = { completed: 0, uncompleted: 0 }
          else
            data = { late: 0, on_time: 0 }
          end

          buckets.each_with_object({}) do |h|
            key = h['key']
            value = h['doc_count'] || 0

            data[h_key(key)] = value
          end

          stats[h_key(param)] = data
        end
      end
    end

    def get_other_aggregations
      OTHER_AGGREGATIONS.each_with_object({}) do |param|
        buckets = aggregations.dig(param, param, 'buckets')

        unless buckets.empty?
          data = {}
          buckets.each_with_object({}) do |h|
            key = h['key']
            param_name = "#{param.to_s.singularize}_name"
            values = {}

            values[h_key(:name)] = h.dig('name', 'hits', 'hits', 0,  '_source', param_name)
            values[h_key(:count)] = h['doc_count'] || 0

            data[h_key(key)] = values
          end

          stats[h_key(param)] = data
        end
      end
    end

    def get_total_count_for(param)
      value = aggregations.dig(param, 'doc_count') || 0

      stats[h_key(param)] = { count: value }
    end

    def count_by_date(param)
      aggs_data = {}
      count_param = "#{param}_count"
      params = aggregations.dig(param, count_param, 'buckets')

      params.each_with_object({}) do |h|
        key = h['key']
        value = h['doc_count'] || 0

        aggs_data[h_key(key)] = value
      end

      stats[h_key(param)].merge!({ aggs: aggs_data })
    end
  end
end
