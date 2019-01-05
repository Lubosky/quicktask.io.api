# frozen_string_literal: true

#
# Used to filter Task collections by set of params
#

module Finders
  class TaskFinder < Finders::BaseFinder
    AGGREGATIONS = %i[status completed_status]

    OVERDUE = 'overdue'.freeze
    COMPLETED = 'completed'.freeze
    UNCOMPLETED = 'uncompleted'.freeze

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

    def execute
      super

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
        date = nil
      elsif start_date_filter == THIRTY_DAYS
        date = { gte: Date.today - 30.days }
      elsif start_date_filter == SIXTY_DAYS
        date = { gte: Date.today - 60.days }
      elsif start_date_filter == NINETY_DAYS
        date = { gte: Date.today - 90.days }
      end

      term = date.nil? ? nil : { gte: date.beginning_of_day }

      query.tap { |h| h[:start_date] = term }
    end

    def by_due_date
      if due_date_filter.present?
        if due_date_filter == NONE
          term = nil
        elsif due_date_filter == OVERDUE
          term = { lte: Time.current }
        elsif due_date_filter == TODAY
          term = start_of_today..end_of_today
        elsif due_date_filter == TOMORROW
          term = start_of_tomorrow..end_of_tomorrow
        elsif due_date_filter == THIS_WEEK
          term = start_of_week..end_of_week
        elsif due_date_filter == THIS_MONTH
          term = start_of_month..end_of_month
        end

        query.tap { |h| h[:due_date] = term }
      end
    end

    def by_completed_date
      if completed_date_filter.present?
        return query.tap { |h| h[:completed_status] = 'late' } if completed_date_filter == LATE

        if completed_date_filter == TODAY
          term = start_of_today..end_of_today
        elsif completed_date_filter == YESTERDAY
          term = start_of_yesterday..end_of_yesterday
        elsif completed_date_filter == THIS_WEEK
          term = start_of_week..end_of_week
        elsif completed_date_filter == THIS_MONTH
          term = start_of_month..end_of_month
        elsif completed_date_filter == PREVIOUS_MONTH
          term = start_of_previous_month..end_of_previous_month
        end

        query.tap { |h| h[:completed_date] = term }
      end
    end

    def order
      case options[:sort].presence.to_s
      when 'due_date_asc'  then { due_date: :asc }
      when 'due_date_desc' then { due_date: :desc }
      when 'completed_date_desc' then { completed_date: :desc }
      else super end
    end

    def body_options
      @agg_filters ||= set_agg_filters

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
            aggs: set_date_ranges(key: :due, param: :due_date)
          },
          completed_date: {
            filter: set_current_agg_filters(:status, COMPLETED),
            aggs: set_date_ranges(key: :completed, param: :completed_date)
          },
        }
      }
    end

    def date_ranges(key)
      case key
      when :due
        due_date_ranges
      else
        default_date_ranges(key)
      end
    end

    def due_date_ranges
      [
        { key: 'no_due_date', to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: 'overdue', from: past_date.tomorrow.strftime(DATE_FORMAT), to: Time.current },
        { key: 'due_today', from: start_of_today, to: end_of_today },
        { key: 'due_tomorrow', from: start_of_tomorrow, to: end_of_tomorrow },
        { key: 'due_this_week', from: start_of_week, to: end_of_week },
        { key: 'due_this_month', from: start_of_month, to: end_of_month }
      ]
    end
  end
end
