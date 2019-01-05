# frozen_string_literal: true

#
# Used to filter Quote collections by set of params
#

module Finders
  class QuoteFinder < Finders::BaseFinder
    AGGREGATIONS = %i[status]

    NO_DUE_DATE = 'no_due_date'.freeze
    DUE_TODAY = 'due_today'.freeze
    DUE_TOMORROW = 'due_tomorrow'.freeze
    DUE_THIS_WEEK = 'due_this_week'.freeze
    DUE_THIS_MONTH = 'due_this_month'.freeze

    def valid_params
      @valid_params ||= %i[
        client_id
        owner_id
        status
        exclude_status
        expiry_date
        accepted_at
        cancelled_at
        declined_at
        created_at
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
        Quote.search(search_query,
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
      by_client
      by_owner
      by_expiry_date
      by_created_date
      by_date('accepted')
      by_date('cancelled')
      by_date('declined')
    end

    def scope_filter
      filters[:scope].presence
    end

    def status_filter
      filters[:status].presence
    end

    def exclude_status_filter
      filters[:exclude_status].presence
    end

    def client_filter
      filters[:client_id].presence
    end

    def owner_filter
      filters[:owner_id].presence
    end

    def expiry_date_filter
      filters[:expiry_date].presence
    end

    def accepted_date_filter
      filters[:accepted_at].presence
    end

    def cancelled_date_filter
      filters[:cancelled_at].presence
    end

    def declined_date_filter
      filters[:declined_at].presence
    end

    def created_date_filter
      filters[:created_at].presence
    end

    private

    def by_scope
      return unless scope_filter.present? && scope_filter.to_s.downcase == ME
      query.tap { |h| h[:owner_id] = user.id }
    end

    def by_status
      query.tap { |h| h[:status] = status_filter } if status_filter.present?
      query.tap { |h| h[:_and] = [{ status: { not: exclude_status_filter } }] } if exclude_status_filter.present?
    end

    def by_client
      query.tap { |h| h[:client_id] = client_filter } if client_filter.present?
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

    def by_created_date
      return if created_date_filter == ALL || created_date_filter.blank?

      if created_date_filter == NONE
        date = nil
      elsif created_date_filter == THIRTY_DAYS
        date = Date.today - 30.days
      elsif created_date_filter == SIXTY_DAYS
        date = Date.today - 60.days
      elsif created_date_filter == NINETY_DAYS
        date = Date.today - 90.days
      end

      term = date.nil? ? nil : { gte: date.beginning_of_day }

      query.tap { |h| h[:created_at] = term }
    end

    def by_expiry_date
      if expiry_date_filter.present?
        if expiry_date_filter == NONE
          term = nil
        elsif expiry_date_filter == EXPIRED
          term = { lte: Time.current }
        elsif expiry_date_filter == TODAY
          term = start_of_today..end_of_today
        elsif expiry_date_filter == TOMORROW
          term = start_of_tomorrow..end_of_tomorrow
        elsif expiry_date_filter == THIS_WEEK
          term = start_of_week..end_of_week
        elsif expiry_date_filter == THIS_MONTH
          term = start_of_previous_month..end_of_previous_month
        end

        query.tap { |h| h[:expiry_date] = term }
      end
    end

    def by_date(key)
      filter = send("#{key}_date_filter")
      param = "#{key}_at"

      if filter.present?
        if filter == NONE
          term = nil
        elsif filter == TODAY
          term = start_of_today..end_of_today
        elsif filter == YESTERDAY
          term = start_of_yesterday..end_of_yesterday
        elsif filter == THIS_WEEK
          term = start_of_week..end_of_week
        elsif filter == THIS_MONTH
          term = start_of_month..end_of_month
        elsif filter == PREVIOUS_WEEK
          term = start_of_previous_week..end_previous_of_week
        elsif filter == PREVIOUS_MONTH
          term = start_of_previous_month..end_of_previous_month
        end

        query.tap { |h| h[param.to_sym] = term }
      end
    end

    def order
      case options[:sort].presence.to_s
      when 'expiry_date_desc'  then { expiry_date: :desc }
      when 'accepted_date_desc'  then { accepted_date: :desc }
      when 'cancelled_date_desc'  then { cancelled_at: :desc }
      when 'declined_date_desc'  then { declined_at: :desc }
      when 'created_date_desc'  then { created_at: :desc }
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
                  name: { top_hits: { size: 1, _source: { include: ['client'] } } }
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
          expiry_date: {
            filter: @agg_filters,
            aggs: set_date_ranges(key: :expiry, param: :expiry_date)
          },
          accepted_date: {
            filter: set_current_agg_filters(:status, 'accepted'),
            aggs: set_date_ranges(key: :accepted, param: :accepted_at)
          },
          cancelled_date: {
            filter: set_current_agg_filters(:status, 'cancelled'),
            aggs: set_date_ranges(key: :cancelled, param: :cancelled_at)
          },
          declined_date: {
            filter: set_current_agg_filters(:status, 'declined'),
            aggs: set_date_ranges(key: :declined, param: :declined_at)
          },
        }
      }
    end

    def date_ranges(key)
      case key
      when :expired
        expired_date_ranges
      else
        default_date_ranges(key)
      end
    end

    def expired_date_ranges
      [
        { key: 'no_expired_date', to: past_date.end_of_day.strftime(DATE_FORMAT) },
        { key: 'expired', from: past_date.tomorrow.strftime(DATE_FORMAT), to: Time.current },
        { key: 'expired_today', from: start_of_today, to: end_of_today },
        { key: 'expired_tomorrow', from: start_of_tomorrow, to: end_of_tomorrow },
        { key: 'expired_this_week', from: start_of_week, to: end_of_week },
        { key: 'expired_this_month', from: start_of_month, to: end_of_month }
      ]
    end
  end
end
