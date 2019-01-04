# frozen_string_literal: true

#
# Used to filter ClientRequest collections by set of params
#
# Arguments:
#   user - which account use
#   params:
#     assignee_id: integer or 'me' or 'none' or 'any'
#     owner_id: integer
#     project_id: integer
#     start_date: date or 'none', 'all', '30_days', '60_days', '90_days'
#     due_date: date or 'none', 'overdue', 'today', 'week', or 'month'
#     created_before: datetime
#     updated_after: datetime
#     updated_before: datetime
#     status: 'completed' or 'uncompleted'
#     scope: 'created_by_me' or 'assigned_to_me' or 'mine'
#     search: string
#     sort: string
#     limit: string
#     offset: string
#     page: string
#

module Finders
  class ClientRequestFinder
    AGGREGATIONS = %i[type status]

    ALL = 'all'.freeze
    ANY = 'any'.freeze
    NONE = 'none'.freeze

    DUE_DATE = 'due_date'.freeze
    ANY_DATE = ''.freeze
    YESTERDAY = 'yesterday'.freeze
    TODAY = 'today'.freeze
    TOMORROW = 'tomorrow'.freeze
    THIS_WEEK = 'week'.freeze
    PREVIOUS_WEEK = 'previous_week'.freeze
    THIS_MONTH = 'month'.freeze
    PREVIOUS_MONTH = 'previous_month'.freeze

    CREATED_TODAY = 'created_today'.freeze
    CREATED_YESTERDAY = 'created_yesterday'.freeze
    CREATED_THIS_WEEK = 'created_this_week'.freeze
    CREATED_THIS_MONTH = 'created_this_month'.freeze
    CREATED_PREVIOUS_WEEK = 'created_previous_week'.freeze
    CREATED_PREVIOUS_MONTH = 'created_previous_month'.freeze

    DATE_FORMAT = '%FT%T%:z'.freeze

    attr_accessor :user, :workspace, :filters, :options, :query

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

    def initialize(user:, workspace: nil, filters: {}, options: {})
      normalized_filters = filters.delete_if {
        |k, v| !k.to_sym.in?(valid_params) ||
          (v.is_a?(Array) ? v.reject!(&:blank?).blank? : v.blank?)
      }.with_indifferent_access

      normalized_options = options.delete_if { |k, v| !k.to_sym.in?(valid_options) }.with_indifferent_access

      @user = user
      @workspace = workspace
      @filters = normalized_filters
      @options = normalized_options
      @query = {}
    end

    def execute
      init_query
      filter_criteria

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
      by_requester
      by_client
      by_service
      by_created_date
    end

    def empty?
      filters.empty?
    end

    def search_query
      filters[:search].presence || '*'
    end

    def type_filter
      filters[:type].presence
    end

    def status_filter
      filters[:status].presence
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

    def init_query
      query.tap do |hash|
        hash[:workspace_id] = workspace.id if workspace.present?
      end
    end

    def by_type
      query.tap { |h| h[:type] = type_filter } if type_filter.present?
    end

    def by_status
      query.tap { |h| h[:status] = status_filter } if status_filter.present?
    end

    def by_project
      query.tap { |h| h[:project_id] = project_filter } if project_filter.present?
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

    def filter_by_created_by_me?
      owner_filter.to_s.downcase == ME
    end

    def by_created_date
      return if created_date_filter == ALL || created_date_filter.blank?

      today = Date.today
      yesterday = Date.yesterday

      if created_date_filter == TODAY
        term = today.beginning_of_day..today.end_of_day
      elsif created_date_filter == YESTERDAY
        term = yesterday.beginning_of_day..yesterday.end_of_day
      elsif created_date_filter == THIS_WEEK
        term = today.beginning_of_week.beginning_of_day..today.end_of_week.end_of_day
      elsif created_date_filter == THIS_MONTH
        term = today.beginning_of_month.beginning_of_day..today.end_of_month.end_of_day
      elsif created_date_filter == PREVIOUS_WEEK
        term = today.prev_week.beginning_of_week.beginning_of_day..today.prev_week.end_of_week.end_of_day
      elsif created_date_filter == PREVIOUS_MONTH
        term = today.prev_month.beginning_of_month.beginning_of_day..today.prev_month.end_of_month.end_of_day
      end

      query.tap { |h| h[:created_at] = date.beginning_of_day }
    end

    def order
      case options[:sort].presence.to_s
      when 'created_date_asc'  then { created_at: :asc }
      when 'created_date_desc'  then { created_at: :desc }
      when 'client_name_asc' then { client: :asc }
      else { updated_at: :desc } end
    end

    def limit
      options[:limit].presence
    end

    def offset
      options[:offset].presence
    end

    def page
      options[:page].presence
    end

    def body_options
      @agg_filters ||= set_agg_filters
      @agg_created_date_ranges ||= set_date_ranges('created_date')

      {
        aggs: {
          clients: {
            filter: @agg_filters,
            aggs: {
              clients: {
                terms: { field: 'client_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['client'] } } }
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
                  name: { top_hits: { size: 1, _source: { include: ['requester'] } } }
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
                  name: { top_hits: { size: 1, _source: { include: ['service'] } } }
                }
              }
            }
          },
          created_at: {
            filter: @agg_filters,
            aggs: @agg_created_date_ranges
          },
        }
      }
    end

    def set_agg_filters
      get_agg_filters
    end

    def get_agg_filters(post_query = nil)
      q = post_query.blank? ? query : post_query

      agg_filters = Hash.new()
      predicate = Hash.new()

      where_filters = Elastic::Query.transform(q)

      predicate[:must] = where_filters
      agg_filters[:bool] = predicate
      return agg_filters
    end

    def set_date_ranges(param)
      agg_hash = Hash.new()
      date_range = Hash.new()
      predicate = Hash.new()
      agg_key = "#{param}_count".to_sym

      predicate[:field] = param
      predicate[:missing] = Date.new(0, 1, 1).strftime(DATE_FORMAT)
      predicate[:ranges] = send("#{param}_ranges")

      date_range[:date_range] = predicate
      agg_hash[agg_key] = date_range

      return agg_hash
    end

    def created_date_ranges
      start_of_today          = Date.today.beginning_of_day.strftime(DATE_FORMAT)
      end_of_today            = Date.today.end_of_day.strftime(DATE_FORMAT)
      start_of_yesterday      = Date.yesterday.beginning_of_day.strftime(DATE_FORMAT)
      end_of_yesterday        = Date.yesterday.end_of_day.strftime(DATE_FORMAT)
      start_of_week           = Date.today.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
      end_of_week             = Date.today.end_of_week.end_of_day.strftime(DATE_FORMAT)
      start_of_month          = Date.today.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
      end_of_month            = Date.today.end_of_month.end_of_day.strftime(DATE_FORMAT)
      start_of_previous_week  = Date.today.prev_week.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
      end_of_previous_week    = Date.today.prev_week.end_of_week.end_of_day.strftime(DATE_FORMAT)
      start_of_previous_month = Date.today.prev_month.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
      end_of_previous_month   = Date.today.prev_month.end_of_month.end_of_day.strftime(DATE_FORMAT)

      return [
        { key: CREATED_TODAY, from: start_of_today, to: end_of_today },
        { key: CREATED_YESTERDAY, from: start_of_yesterday, to: end_of_yesterday },
        { key: CREATED_THIS_WEEK, from: start_of_week, to: end_of_week },
        { key: CREATED_THIS_MONTH, from: start_of_month, to: end_of_month },
        { key: CREATED_PREVIOUS_WEEK, from: start_of_previous_week, to: end_of_previous_month },
        { key: CREATED_PREVIOUS_MONTH, from: start_of_previous_month, to: end_of_previous_week }
      ]
    end
  end
end
