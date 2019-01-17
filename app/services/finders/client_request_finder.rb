# frozen_string_literal: true

#
# Used to filter ClientRequest collections by set of params
#

module Finders
  class ClientRequestFinder < Finders::BaseFinder
    AGGREGATIONS = %i[type status]

    NOT_URGENT = 'not_urgent'.freeze
    URGENT = 'urgent'.freeze

    def valid_params
      @valid_params ||= %i[
        client_id
        requester_id
        service_id
        start_date
        due_date
        created_at
        type
        status
        exclude_status
        scope
        search
      ]
    end

    def valid_options
      @valid_options ||= %i[
        limit
        offset
        page
        sort
      ]
    end

    def execute
      super

      @client_requests ||=
        ClientRequest.search(search_query,
          where: query,
          routing: workspace&.id,
          aggs: AGGREGATIONS,
          body_options: body_options,
          order: order,
          limit: limit,
          offset: offset,
          page: page,
          load: false
        )
    end

    def filter_criteria
      by_type
      by_status
      by_scope
      by_requester
      by_client
      by_service
      by_created_date
    end

    def type_filter
      filters[:type].presence
    end

    def status_filter
      filters[:status].presence
    end

    def scope_filter
      filters[:scope].presence
    end

    def exclude_status_filter
      filters[:exclude_status].presence
    end

    def client_filter
      filters[:client_id].presence
    end

    def requester_filter
      filters[:requester_id].presence
    end

    def service_filter
      filters[:service_id].presence
    end

    def start_date_filter
      filters[:start_date].presence
    end

    def due_date_filter
      filters[:due_date].presence
    end

    def created_date_filter
      filters[:created_at].presence
    end

    private

    def by_type
      return if type_filter == ALL || type_filter.blank?
      query.tap { |h| h[:type] = type_filter }
    end

    def by_status
      query.tap { |h| h[:status] = status_filter } if status_filter.present?
      query.tap { |h| h[:_and] = [{ status: { not: exclude_status_filter } }] } if exclude_status_filter.present?
    end

    def by_scope
      return unless scope_filter.present? &&
        scope_filter.to_s.downcase.in?([URGENT, NOT_URGENT])
      timestamp = Time.current + 3.days
      if scope_filter.to_s.downcase == URGENT
        term = { lte: timestamp.end_of_day }
      else
        term = { gt: timestamp.end_of_day }
      end

      query.tap do |h|
        h[:start_date] = term
        h[:status] = 'pending'
      end
    end

    def by_client
      query.tap { |h| h[:client_id] = client_filter } if client_filter.present?
    end

    def by_requester
      query.tap { |h| h[:requester_id] = requester_filter } if requester_filter.present?
    end

    def by_service
      query.tap { |h| h[:service_id] = service_filter } if service_filter.present?
    end

    def by_created_date
      return if created_date_filter == ALL || created_date_filter.blank?

      if created_date_filter == TODAY
        term = start_of_today..end_of_today
      elsif created_date_filter == YESTERDAY
        term = start_of_yesterday..end_of_yesterday
      elsif created_date_filter == THIS_WEEK
        term = start_of_week..end_of_week
      elsif created_date_filter == THIS_MONTH
        term = start_of_month..end_of_month
      elsif created_date_filter == PREVIOUS_WEEK
        term = start_of_previous_week..end_of_previous_week
      elsif created_date_filter == PREVIOUS_MONTH
        term = start_of_previous_month..end_of_previous_month
      end

      query.tap { |h| h[:created_at] = term }
    end

    def order
      case options[:sort].presence.to_s
      when 'created_date_asc'  then { created_at: :asc }
      when 'created_date_desc'  then { created_at: :desc }
      when 'start_date_asc'  then { start_date: { order: :asc, unmapped_type: :long } }
      when 'client_name_asc' then { client_name: { order: :asc, unmapped_type: :long } }
      else super end
    end

    def body_options
      @agg_filters ||= set_agg_filters

      {
        aggs: {
          clients: {
            filter: @agg_filters,
            aggs: {
              clients: {
                terms: { field: 'client_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['client_name'] } } }
                }
              }
            }
          },
          requesters: {
            filter: @agg_filters,
            aggs: {
              requesters: {
                terms: { field: 'requester_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['requester_name'] } } }
                }
              }
            }
          },
          services: {
            filter: @agg_filters,
            aggs: {
              services: {
                terms: { field: 'service_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['service_name'] } } }
                }
              }
            }
          },
          created_date: {
            filter: @agg_filters,
            aggs: set_date_ranges(key: 'created', param: 'created_at')
          },
          start_date: {
            filter: set_current_agg_filters(:status, 'pending'),
            aggs: set_date_ranges(key: :start, param: :start_date)
          },
          submitted_date: {
            filter: @agg_filters,
            aggs: set_date_ranges(key: :submitted, param: :submitted_at)
          },
          estimated_date: {
            filter: set_current_agg_filters(:status, 'estimated'),
            aggs: set_date_ranges(key: :estimated, param: :estimated_at)
          },
          cancelled_date: {
            filter: set_current_agg_filters(:status, 'cancelled'),
            aggs: set_date_ranges(key: :cancelled, param: :cancelled_at)
          },
          withdrawn_date: {
            filter: set_current_agg_filters(:status, 'withdrawn'),
            aggs: set_date_ranges(key: :withdrawn, param: :withdrawn_at)
          }
        }
      }
    end

    def date_ranges(key)
      case key
      when :start
        start_date_ranges
      else
        default_date_ranges
      end
    end

    def start_date_ranges
      three_days_from_now = Time.current + 3.days

      return [
        { key: 'no_start_date', to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: 'urgent', from: past_date.tomorrow.strftime(DATE_FORMAT), to: three_days_from_now.end_of_day },
        { key: 'remaining', from: three_days_from_now.tomorrow.beginning_of_day }
      ]
    end
  end
end
