module ActiveRecord
  class Relation
    class Merger # :nodoc:
      def normal_values
        NORMAL_VALUES + [:with]
      end
    end
  end
end

module ActiveRecord::Querying
  delegate :with, to: :all
end

module ActiveRecord
  class Relation
    class WithChain
      def initialize(scope)
        @scope = scope
      end

      def recursive(*args)
        @scope.with_values += args
        @scope.recursive_value = true
        @scope
      end
    end

    def with_values
      @values[:with] || []
    end

    def with_values=(values)
      raise ImmutableRelation if @loaded
      @values[:with] = values
    end

    def recursive_value=(value)
      raise ImmutableRelation if @loaded
      @values[:recursive] = value
    end

    def recursive_value
      @values[:recursive]
    end

    def with(opts = :chain, *rest)
      if opts == :chain
        WithChain.new(spawn)
      elsif opts.blank?
        self
      else
        spawn.with!(opts, *rest)
      end
    end

    def with!(opts = :chain, *rest) # :nodoc:
      if opts == :chain
        WithChain.new(self)
      else
        self.with_values += [opts] + rest
        self
      end

    end

    def build_arel(aliases)
      arel = super(aliases)

      build_with(arel) if @values[:with]

      arel
    end

    def build_with(arel)
      with_statements = with_values.flat_map do |with_value|
        case with_value
        when String
          with_value
        when Hash
          with_value.map  do |name, expression|
            case expression
            when String
              select = Arel::Nodes::SqlLiteral.new "(#{expression})"
            when ActiveRecord::Relation, Arel::SelectManager
              select = Arel::Nodes::SqlLiteral.new "(#{expression.to_sql})"
            end
            Arel::Nodes::As.new Arel::Nodes::SqlLiteral.new(PG::Connection.quote_ident(name.to_s)), select
          end
        when Arel::Nodes::As
          with_value
        end
      end

      unless with_statements.empty?
        if recursive_value
          arel.with :recursive, with_statements
        else
          arel.with with_statements
        end
      end
    end
  end
end
