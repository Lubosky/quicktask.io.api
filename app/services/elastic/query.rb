# frozen_string_literal: true

module Elastic
  class Query
    def self.transform(query)
      new(query).call
    end

    def initialize(query)
      @query = query
    end

    def call
      transform_filters(@query)
    end

    private

    def transform_filters(where)
      filters = []
      (where || {}).each do |field, value|
        field = :_id if field.to_s == 'id'

        if field == :or
          value.each do |or_clause|
            filters << { bool: { should: or_clause.map { |or_statement| { bool: { filter: transform_filters(or_statement) } } } } }
          end
        elsif field == :_or
          filters << { bool: { should: value.map { |or_statement| { bool: { filter: transform_filters(or_statement) } } } } }
        elsif field == :_not
          filters << { bool: { must_not: transform_filters(value) } }
        elsif field == :_and
          filters << { bool: { must: value.map { |or_statement| { bool: { filter: transform_filters(or_statement) } } } } }
        else
          if value.is_a?(Range)
            value = { gte: value.first, (value.exclude_end? ? :lt : :lte) => value.last }
          end

          value = { in: value } if value.is_a?(Array)

          if value.is_a?(Hash)
            value.each do |op, op_value|
              case op
              when :within, :bottom_right, :bottom_left
              when :near
                filters << {
                  geo_distance: {
                    field => location_value(op_value),
                    distance: value[:within] || '100km'
                  }
                }
              when :geo_polygon
                filters << {
                  geo_polygon: {
                    field => op_value
                  }
                }
              when :geo_shape
                shape = op_value.except(:relation)
                shape[:coordinates] = coordinate_array(shape[:coordinates]) if shape[:coordinates]
                filters << {
                  geo_shape: {
                    field => {
                      relation: op_value[:relation] || 'intersects',
                      shape: shape
                    }
                  }
                }
              when :top_left
                filters << {
                  geo_bounding_box: {
                    field => {
                      top_left: location_value(op_value),
                      bottom_right: location_value(value[:bottom_right])
                    }
                  }
                }
              when :top_right
                filters << {
                  geo_bounding_box: {
                    field => {
                      top_right: location_value(op_value),
                      bottom_left: location_value(value[:bottom_left])
                    }
                  }
                }
              when :prefix
                filters << { prefix: { field => op_value } }
              when :regexp
                filters << { regexp: { field => { value: op_value } } }
              when :not, :_not
                filters << { bool: { must_not: term_filters(field, op_value) } }
              when :all
                op_value.each do |val|
                  filters << term_filters(field, val)
                end
              when :in
                filters << term_filters(field, op_value)
              else
                range_query =
                  case op
                  when :gt
                    { from: op_value, include_lower: false }
                  when :gte
                    { from: op_value, include_lower: true }
                  when :lt
                    { to: op_value, include_upper: false }
                  when :lte
                    { to: op_value, include_upper: true }
                  else
                    raise "Unknown where operator: #{op.inspect}"
                  end
                if (existing = filters.find { |f| f[:range] && f[:range][field] })
                  existing[:range][field].merge!(range_query)
                else
                  filters << { range: { field => range_query } }
                end
              end
            end
          else
            filters << term_filters(field, value)
          end
        end
      end
      filters
    end

    def term_filters(field, value)
      if value.is_a?(Array)
        if value.any?(&:nil?)
          { bool: { should: [term_filters(field, nil), term_filters(field, value.compact)] } }
        else
          { terms: { field => value } }
        end
      elsif value.nil?
        { bool: { must_not: { exists: { field: field } } } }
      elsif value.is_a?(Regexp)
        { regexp: { field => { value: value.source, flags: 'NONE' } } }
      else
        { term: { field => value } }
      end
    end
  end
end
