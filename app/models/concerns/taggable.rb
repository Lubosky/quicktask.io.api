module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, class_name: 'Tagging', as: :taggable
    has_many :tags, class_name: 'Tag', through: :taggings, dependent: :destroy do
      def << (values)
        values -= self if values.respond_to?(:to_a)
        super values unless include?(values)
      end
    end

    after_save :persist_tags
    after_commit :reset_tag_names, on: %i[ create update ]

    def reset_tag_names
      return if tag_names_previously_changed?
      @attributes.write_from_database 'tag_names', nil
    end

    def tag_names
      self.tag_names = tags.pluck(:name) if super.nil?
      super
    end

    def tag_names=(values)
      @attributes.write_from_database 'tag_names', []
      super Tagged::TagNames.call(values)
    end

    attribute 'tag_names', ActiveRecord::Type::Value.new, default: nil

    private

    def persist_tags
      Tagged::Persistence.new(Tagged::ChangeState.new(self)).persist
    end
  end

  module ClassMethods
    def tagged_with(options)
      Tagged::TaggedWith.call self, options
    end
  end
end
