class ApplicationInteractor < ActiveInteraction::Base
  alias :success? :valid?

  module Context
    extend ActiveSupport::Concern

    included do
      hash :context, default: {} do
        object :current_user, default: nil, class: User
        object :current_workspace, default: nil, class: Workspace
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def current_workspace
      context[:current_workspace]
    end
  end
  include Context

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def base_class(value = nil)
        @base_class ||= value || name.deconstantize.safe_constantize
      end

      def action(value = nil)
        @action ||= value || name.demodulize.underscore.to_sym
      end
    end

    def action
      self.class.action
    end

    def base_class
      self.class.base_class
    end
  end
  include Base

  module Logging
    extend ActiveSupport::Concern

    included do
      class_attribute :logger
      self.logger = Rails.logger

      set_callback :type_check, :before, -> { logger.debug { "#{self.class} inputs #{inputs.inspect}" } }
      set_callback :execute, :around, lambda { |_, block|
        begin
          block.call
        rescue ActiveRecord::RecordNotUnique => e
          case e.message
          when /Key \((.+)\)=/
            errors.add($1.to_sym, :taken)
          else
            errors.add(:base, :taken)
          end
        end
      }
    end
  end
  include Logging

  module Instrumentation
    extend ActiveSupport::Concern

    included do
      set_callback :execute, :around, lambda { |_, block|
        event_name = "execute.#{self.class._instrumentation_name}"
        payload = { class: self.class, inputs: inputs.dup }
        ActiveSupport::Notifications.instrument(event_name, payload) do
          block.call
        end
      }
    end

    INSTRUMENTATION_EVENT_SUFFIX = 'active_interaction'.freeze

    module ClassMethods
      def _instrumentation_name
        (name.downcase.squeeze(':').split(':').reverse << INSTRUMENTATION_EVENT_SUFFIX).join('.')
      end
    end
  end
  include Instrumentation

  module Attributes
    extend ActiveSupport::Concern

    private

    def attributes
      inputs.reject { |input, _| input.in?([:context]) }
    end

    def given_attributes
      attributes.select { |input, _val| given?(input) }
    end
  end
  include Attributes

  module Transaction
    extend ActiveSupport::Concern

    private

    def transaction(&_block)
      ApplicationRecord.transaction do
        yield
      end
    end

    def rollback
      fail ActiveRecord::Rollback
    end
  end
  include Transaction

  module Authorization
    extend ActiveSupport::Concern
    class NotAuthorized < ::Pundit::NotAuthorizedError
      attr_reader :query, :model, :policy

      def initialize(options = {})
        if options.is_a? String
          message = options
        else
          @query = options[:query]
          @model = options[:model]
          @policy = options[:policy]

          message = options.fetch(:message) { "not allowed to #{query} #{model.is_a?(Class) ? model.name : model.class.name}" }
        end

        super(message)
      end
    end

    def authorize(model, query = nil)
      query ||= action.to_s + '?'

      policy = policy(model)

      unless policy.public_send(query)
        raise NotAuthorized, query: query, model: model, policy: policy
      end

      model
    end

    private

    def policies
      @_policies ||= {}
    end

    def policy(model)
      policies[model] ||= Pundit.policy!(current_user, model)
    end

    def policy_scopes
      @_policy_scopes ||= {}
    end

    def policy_scope(scope)
      policy_scopes[scope] ||= Pundit.policy_scope!(current_user, scope)
    end
  end
  include Authorization

  module Helpers
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      private

      def default_attrs(*attrs, **args)
        attrs.each do |attr|
          if args[:array]
            array attr, default: -> { model.try(attr) unless given?(attr) } do
              send args[:type]
            end
          else
            send args[:type], attr, default: -> { model.try(attr) unless given?(attr) }
          end
        end
      end
    end
  end
  include Helpers
end
