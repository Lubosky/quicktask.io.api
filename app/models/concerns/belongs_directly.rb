module BelongsDirectly
  extend ActiveSupport::Concern

  module ClassMethods
    def belongs_directly_to(name, options={})
      define_method :"assign_attribute_#{name}" do
        foreign_key = options.key?(:foreign_key) ? options[:foreign_key] : "#{name}_id"
        primary_key = options.key?(:primary_key) ? options[:primary_key] : 'id'

        if relation = self.public_send(name)
          self.public_send :"#{foreign_key}=", relation.public_send(primary_key)
        end
      end

      self.before_validation :"assign_attribute_#{name}"
    end
  end
end
