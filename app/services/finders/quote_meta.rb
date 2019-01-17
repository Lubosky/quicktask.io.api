# frozen_string_literal: true

module Finders
  class QuoteMeta < Finders::BaseMeta
    DATE_AGGREGATIONS = %w(accepted_date cancelled_date created_date declined_date expired_date expiry_date sent_date)
    STATUS_AGGREGATIONS = %w(status)
    OTHER_AGGREGATIONS = %w(clients owners)

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
          data = { draft: 0, sent: 0, accepted: 0, declined: 0, expired: 0, cancelled: 0 }

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
          data = Hash.new()
          buckets.each_with_object({}) do |h|
            key = h['key']
            param_name = "#{param.to_s.singularize}_name"
            values = Hash.new()

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
      aggs_data = Hash.new()
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
