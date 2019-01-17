# frozen_string_literal: true

module Finders
  class BaseFinder
    AGGREGATIONS = %i[status completed_status]

    ALL = 'all'.freeze
    ANY = 'any'.freeze
    NONE = 'none'.freeze
    ME = 'me'.freeze

    ANY_DATE = ''.freeze
    YESTERDAY = 'yesterday'.freeze
    TODAY = 'today'.freeze
    TOMORROW = 'tomorrow'.freeze
    THIS_WEEK = 'week'.freeze
    THIS_MONTH = 'month'.freeze
    PREVIOUS_WEEK = 'previous_week'.freeze
    PREVIOUS_MONTH = 'previous_month'.freeze

    SEVEN_DAYS = '7_days'.freeze
    THIRTY_DAYS = '30_days'.freeze
    SIXTY_DAYS = '60_days'.freeze
    NINETY_DAYS = '90_days'.freeze

    DATE_FORMAT = '%FT%T%:z'.freeze

    attr_accessor :user, :workspace, :filters, :options, :query

    def valid_params
      raise NotImplementedError.new
    end

    def valid_options
      raise NotImplementedError.new
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
    end

    def filter_criteria
      raise NotImplementedError.new
    end

    def empty?
      filters.empty?
    end

    def search_query
      filters[:search].presence || '*'
    end

    private

    def init_query
      query.tap do |hash|
        hash[:workspace_id] = workspace.id if workspace.present?
      end
    end

    def order
      { updated_at: :desc }
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
      where_filters = Elastic::Query.transform(q)

      return { bool: { must: where_filters } }
    end

    def set_date_ranges(key:, param:)
      agg_hash = Hash.new()
      agg_key = "#{key}_date_count".to_sym
      missing = Date.new(0, 1, 1).strftime(DATE_FORMAT)

      return { agg_key => { date_range: { field: param, missing: missing, ranges: date_ranges(key) } } }
    end

    def date_ranges(key)
      default_date_ranges
    end

    def default_date_ranges
      [
        { key: "none", to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: "today", from: start_of_today, to: end_of_today },
        { key: "yesterday", from: start_of_yesterday, to: end_of_yesterday },
        { key: "this_week", from: start_of_week, to: end_of_week },
        { key: "this_month", from: start_of_month, to: end_of_month },
        { key: "previous_week", from: start_of_previous_week, to: end_of_previous_week },
        { key: "previous_month", from: start_of_previous_month, to: end_of_previous_month }
      ]
    end

    def past_date
      Date.new(0, 1, 1)
    end

    def start_of_today
      Date.today.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_today
      Date.today.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_tomorrow
      Date.tomorrow.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_tomorrow
      Date.tomorrow.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_yesterday
      Date.yesterday.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_yesterday
      Date.yesterday.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_week
      Date.today.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_week
      Date.today.end_of_week.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_previous_week
      Date.today.prev_week.beginning_of_week.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_previous_week
      Date.today.prev_week.end_of_week.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_month
      Date.today.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_month
      Date.today.end_of_month.end_of_day.strftime(DATE_FORMAT)
    end

    def start_of_previous_month
      Date.today.prev_month.beginning_of_month.beginning_of_day.strftime(DATE_FORMAT)
    end

    def end_of_previous_month
      Date.today.prev_month.end_of_month.end_of_day.strftime(DATE_FORMAT)
    end
  end
end
