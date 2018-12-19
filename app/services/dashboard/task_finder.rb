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

module Dashboard
  class TaskFinder
    AGGREGATIONS = %i[assignee_id status completed_status]

    ALL = 'all'.freeze
    ANY = 'any'.freeze
    NONE = 'none'.freeze
    ME = 'me'.freeze

    ANY_DATE = ''.freeze
    OVERDUE = 'overdue'.freeze
    LATE = 'late'.freeze
    TODAY = 'today'.freeze
    TOMORROW = 'tomorrow'.freeze
    THIS_WEEK = 'week'.freeze
    THIS_MONTH = 'month'.freeze

    THIRTY_DAYS = '30_days'.freeze
    SIXTY_DAYS = '60_days'.freeze
    NINETY_DAYS = '90_days'.freeze

    NO_DUE_DATE = 'no_due_date'.freeze
    DUE_TODAY = 'due_today'.freeze
    DUE_TOMORROW = 'due_tomorrow'.freeze
    DUE_THIS_WEEK = 'due_this_week'.freeze
    DUE_THIS_MONTH = 'due_this_month'.freeze

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
          term = { lte: Date.today }
        elsif due_date_filter == TODAY
          term = Date.today
        elsif due_date_filter == TOMORROW
          term = Date.tomorrow
        elsif due_date_filter == THIS_WEEK
          term = Date.today.beginning_of_week..Date.today.end_of_week
        elsif due_date_filter == THIS_MONTH
          term = Date.today.beginning_of_month..Date.today.end_of_month
        end

        query.tap { |h| h[:due_on] = term }
      end
    end

    def by_completed_date
      if completed_date_filter.present?
        return query.tap { |h| h[:completed_status] = 'late' } if completed_date_filter == LATE

        if completed_date_filter == TODAY
          term = Date.today
        elsif completed_date_filter == THIS_WEEK
          term = Date.today.beginning_of_week..Date.today.end_of_week
        elsif completed_date_filter == THIS_MONTH
          term = Date.today.beginning_of_month..Date.today.end_of_month
        end

        query.tap { |h| h[:completed_on] = term }
      end
    end

    def order
      case options[:sort].presence.to_s
      when 'due_date_asc'  then { due_date: :asc }
      when 'due_date_desc' then { due_date: :desc }
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
      {
        aggs: {
          task: {
            filter: { term: { status: UNCOMPLETED } },
            aggs: aggregation_hash
          },
          assignee: {
            filter: { term: { assignee_id: user.id } },
            aggs: aggregation_hash
          },
          owner: {
            filter: { term: { owner_id: user.id } },
            aggs: aggregation_hash
          }
        }
      }
    end

    def aggregation_hash
      {
        due_date_count: {
          date_range: {
            field: DUE_DATE,
            missing: Date.new(0, 1, 1).strftime(DATE_FORMAT),
            ranges: date_ranges
          }
        }
      }
    end

    def date_ranges
      past_date           = Date.new(0, 1, 1)
      yesterday           = Date.yesterday.end_of_day.strftime(DATE_FORMAT)
      today               = Date.today.strftime(DATE_FORMAT)
      today_end_of_day    = Date.today.end_of_day.strftime(DATE_FORMAT)
      tomorrow            = Date.tomorrow.strftime(DATE_FORMAT)
      tomorrow_end_of_day = Date.tomorrow.end_of_day.strftime(DATE_FORMAT)
      day_after_tomorrow  = (Date.tomorrow + 1.day).strftime(DATE_FORMAT)
      end_of_week         = Date.today.end_of_week.end_of_day.strftime(DATE_FORMAT)
      next_week           = Date.today.next_week.strftime(DATE_FORMAT)
      end_of_month        = Date.today.end_of_month.end_of_day.strftime(DATE_FORMAT)

      return [
        { key: NO_DUE_DATE, to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: OVERDUE, from: past_date.tomorrow.strftime(DATE_FORMAT), to: yesterday },
        { key: DUE_TODAY, from: today, to: today_end_of_day },
        { key: DUE_TOMORROW, from: tomorrow, to: tomorrow_end_of_day },
        { key: DUE_THIS_WEEK, from: day_after_tomorrow, to: end_of_week },
        { key: DUE_THIS_MONTH, from: next_week, to: end_of_month }
      ]
    end
  end
end
