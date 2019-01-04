# frozen_string_literal: true

#
# Used to filter Task collections by set of params
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
  class TaskFinder
    AGGREGATIONS = %i[status completed_status]

    ALL = 'all'.freeze
    ANY = 'any'.freeze
    NONE = 'none'.freeze
    ME = 'me'.freeze

    ANY_DATE = ''.freeze
    OVERDUE = 'overdue'.freeze
    LATE = 'late'.freeze
    YESTERDAY = 'yesterday'.freeze
    TODAY = 'today'.freeze
    TOMORROW = 'tomorrow'.freeze
    THIS_WEEK = 'week'.freeze
    THIS_MONTH = 'month'.freeze
    PREVIOUS_MONTH = 'previous_month'.freeze

    THIRTY_DAYS = '30_days'.freeze
    SIXTY_DAYS = '60_days'.freeze
    NINETY_DAYS = '90_days'.freeze

    NO_DUE_DATE = 'no_due_date'.freeze
    DUE_TODAY = 'due_today'.freeze
    DUE_TOMORROW = 'due_tomorrow'.freeze
    DUE_THIS_WEEK = 'due_this_week'.freeze
    DUE_THIS_MONTH = 'due_this_month'.freeze

    NO_COMPLETED_DATE = 'no_completed_date'.freeze
    COMPLETED_TODAY = 'completed_today'.freeze
    COMPLETED_YESTERDAY = 'completed_yesterday'.freeze
    COMPLETED_THIS_WEEK = 'completed_this_week'.freeze
    COMPLETED_THIS_MONTH = 'completed_this_month'.freeze
    COMPLETED_PREVIOUS_MONTH = 'completed_previous_month'.freeze

    DUE_DATE = 'due_date'.freeze
    COMPLETED = 'completed'.freeze
    UNCOMPLETED = 'uncompleted'.freeze

    DATE_FORMAT = '%FT%T%:z'.freeze

    attr_accessor :user, :workspace, :filters, :options, :query

    def valid_params
      @valid_params ||= %i[
        assignee_id
        owner_id
        project_id
        start_date
        due_date
        completed_date
        status
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

      @tasks ||=
        Task.search(search_query,
          where: query,
          misspellings: { fields: [:description] },
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
      by_scope
      by_status
      by_assignee
      by_owner
      by_project
      by_start_date
      by_due_date
      by_completed_date
    end

    def empty?
      filters.empty?
    end

    def search_query
      filters[:search].presence || '*'
    end

    def scope_filter
      filters[:scope].presence
    end

    def status_filter
      filters[:status].presence
    end

    def assignee_filter
      filters[:assignee_id].presence
    end

    def owner_filter
      filters[:owner_id].presence
    end

    def project_filter
      filters[:project_id].presence
    end

    def start_date_filter
      filters[:start_date].presence
    end

    def due_date_filter
      filters[:due_date].presence
    end

    def completed_date_filter
      filters[:completed_date].presence
    end

    private

    def init_query
      query.tap do |hash|
        hash[:workspace_id] = workspace.id if workspace.present?
      end
    end

    def by_scope
      return unless scope_filter.present? && scope_filter.to_s.downcase == ME
      assignee_param = {}.tap { |h| h[:assignee_id] = user.id }
      owner_param = {}.tap { |h| h[:owner_id] = user.id }

      query.tap { |h| h[:_or] =  [assignee_param, owner_param] }
    end

    def by_status
      query.tap { |h| h[:status] = status_filter } if status_filter.present?
    end

    def by_project
      query.tap { |h| h[:project_id] = project_filter } if project_filter.present?
    end

    def by_assignee
      return unless assignee_filter.present?

      if no_assignee?
        term = nil
      elsif any_assignee?
        term = { not: nil }
      elsif assigned_to_me?
        term = user.id
      elsif assignee?
        term = assignee_filter
      end

      query.tap { |h| h[:assignee_id] = term }
    end

    def assignee?
      assignee_filter.to_s.downcase != NONE
    end

    def no_assignee?
      assignee_filter.to_s.downcase == NONE
    end

    def any_assignee?
      assignee_filter.to_s.downcase == ANY
    end

    def assigned_to_me?
      assignee_filter.to_s.downcase == ME
    end

    def by_owner
      return unless owner_filter.present?

      if filter_by_created_by_me?
        term = user.id
      else
        term = owner_filter
      end

      query.tap { |h| h[:owner_id] = term }
    end

    def filter_by_created_by_me?
      owner_filter.to_s.downcase == ME
    end

    def by_start_date
      return if start_date_filter == ALL || start_date_filter.blank?

      if start_date_filter == NONE
        term = nil
      elsif start_date_filter == THIRTY_DAYS
        term = { gte: Date.today - 30.days }
      elsif start_date_filter == SIXTY_DAYS
        term = { gte: Date.today - 60.days }
      elsif start_date_filter == NINETY_DAYS
        term = { gte: Date.today - 90.days }
      end

      query.tap { |h| h[:start_on] = term }
    end

    def by_due_date
      if due_date_filter.present?
        if due_date_filter == NONE
          term = nil
        elsif due_date_filter == OVERDUE
          term = { lte: Time.current }
        elsif due_date_filter == TODAY
          term = Date.today.beginning_of_day..Date.today.end_of_day
        elsif due_date_filter == TOMORROW
          term = Date.tomorrow.beginning_of_day..Date.tomorrow.end_of_day
        elsif due_date_filter == THIS_WEEK
          term = Date.today.beginning_of_week.beginning_of_day..Date.today.end_of_week.end_of_day
        elsif due_date_filter == THIS_MONTH
          term = Date.today.beginning_of_month.beginning_of_day..Date.today.end_of_month.end_of_day
        end

        query.tap { |h| h[:due_date] = term }
      end
    end

    def by_completed_date
      if completed_date_filter.present?
        return query.tap { |h| h[:completed_status] = 'late' } if completed_date_filter == LATE

        if completed_date_filter == TODAY
          term = Date.today.beginning_of_day..Date.today.end_of_day
        elsif completed_date_filter == YESTERDAY
          term = Date.yesterday.beginning_of_day..Date.yesterday.end_of_day
        elsif completed_date_filter == THIS_WEEK
          term = Date.today.beginning_of_week.beginning_of_day..Date.today.end_of_week.end_of_day
        elsif completed_date_filter == THIS_MONTH
          term = Date.today.beginning_of_month.beginning_of_day..Date.today.end_of_month.end_of_day
        elsif completed_date_filter == PREVIOUS_MONTH
          term = Date.today.prev_month.beginning_of_month.beginning_of_day..Date.today.prev_month.end_of_month.end_of_day
        end

        query.tap { |h| h[:completed_date] = term }
      end
    end

    def order
      case options[:sort].presence.to_s
      when 'due_date_asc'  then { due_date: :asc }
      when 'due_date_desc' then { due_date: :desc }
      when 'completed_date_desc' then { completed_date: :desc }
      else { updated_date: :desc } end
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

    def order_due_date_asc
      { due_date: :asc }
    end

    def order_due_date_desc
      { due_date: :desc }
    end

    def body_options
      @agg_filters ||= set_agg_filters
      @agg_due_date_ranges ||= set_date_ranges('due_date')
      @agg_completed_date_ranges ||= set_date_ranges('completed_date')

      {
        aggs: {
          assignees: {
            filter: @agg_filters,
            aggs: {
              assignees: {
                terms: { field: 'assignee_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['assignee'] } } }
                }
              }
            }
          },
          owners: {
            filter: @agg_filters,
            aggs: {
              owners: {
                terms: { field: 'owner_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['owner'] } } }
                }
              }
            }
          },
          projects: {
            filter: @agg_filters,
            aggs: {
              projects: {
                terms: { field: 'project_id', size: 100 },
                aggs: {
                  name: { top_hits: { size: 1, _source: { include: ['project'] } } }
                }
              }
            }
          },
          due_date: {
            filter: set_current_agg_filters(:status, UNCOMPLETED),
            aggs: @agg_due_date_ranges
          },
          completed_date: {
            filter: set_current_agg_filters(:status, COMPLETED),
            aggs: @agg_completed_date_ranges
          },
        }
      }
    end

    def set_agg_filters
      get_agg_filters
    end

    def set_current_agg_filters(key, value)
      where = query.dup
      where.merge!({ key => value })

      get_agg_filters(where)
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

    def completed_date_ranges
      past_date               = Date.new(0, 1, 1)
      start_of_today          = Date.today.beginning_of_day.strftime(DATE_FORMAT)
      end_of_today            = Date.today.end_of_day.strftime(DATE_FORMAT)
      start_of_yesterday      = Date.yesterday.beginning_of_day.strftime(DATE_FORMAT)
      end_of_yesterday        = Date.yesterday.end_of_day.strftime(DATE_FORMAT)
      start_of_week           = Date.today.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
      end_of_week             = Date.today.end_of_week.end_of_day.strftime(DATE_FORMAT)
      start_of_month          = Date.today.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
      end_of_month            = Date.today.end_of_month.end_of_day.strftime(DATE_FORMAT)
      start_of_previous_month = Date.today.prev_month.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
      end_of_previous_month   = Date.today.prev_month.end_of_month.end_of_day.strftime(DATE_FORMAT)

      return [
        { key: NO_COMPLETED_DATE, to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: COMPLETED_TODAY, from: start_of_today, to: end_of_today },
        { key: COMPLETED_YESTERDAY, from: start_of_yesterday, to: end_of_yesterday },
        { key: COMPLETED_THIS_WEEK, from: start_of_week, to: end_of_week },
        { key: COMPLETED_THIS_MONTH, from: start_of_month, to: end_of_month },
        { key: COMPLETED_PREVIOUS_MONTH, from: start_of_previous_month, to: end_of_previous_month }
      ]
    end

    def due_date_ranges
      past_date         = Date.new(0, 1, 1)
      end_of_yesterday  = Date.yesterday.end_of_day.strftime(DATE_FORMAT)
      start_of_today    = Date.today.beginning_of_day.strftime(DATE_FORMAT)
      end_of_today      = Date.today.end_of_day.strftime(DATE_FORMAT)
      start_of_tomorrow = Date.tomorrow.beginning_of_day.strftime(DATE_FORMAT)
      end_of_tomorrow   = Date.tomorrow.end_of_day.strftime(DATE_FORMAT)
      start_of_week     = Date.today.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
      end_of_week       = Date.today.end_of_week.end_of_day.strftime(DATE_FORMAT)
      start_of_month    = Date.today.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
      end_of_month      = Date.today.end_of_month.end_of_day.strftime(DATE_FORMAT)

      return [
        { key: NO_DUE_DATE, to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: OVERDUE, from: past_date.tomorrow.strftime(DATE_FORMAT), to: Time.current },
        { key: DUE_TODAY, from: start_of_today, to: end_of_today },
        { key: DUE_TOMORROW, from: start_of_tomorrow, to: end_of_tomorrow },
        { key: DUE_THIS_WEEK, from: start_of_week, to: end_of_week },
        { key: DUE_THIS_MONTH, from: start_of_month, to: end_of_month }
      ]
    end
  end
end
