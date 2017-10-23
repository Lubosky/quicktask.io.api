class SerializableError < JSONAPI::Serializable::Error
  def id
    super || SecureRandom.uuid
  end

  class << self
    def from_activemodel_errors(active_model_errors)
      [].tap do |errors|
        active_model_errors.keys.flat_map do |attr|
          active_model_errors.messages[attr].each_with_index do |_message, idx|
            errors << ActiveModelError.new(errors: active_model_errors, error_key: attr, error_index: idx)
          end
        end
      end.map { |e| create(e.attributes) }
    end

    def create(hash)
      hash.each_with_object(new) do |(k, v), e|
        e.instance_variable_set("@_#{k}", v)
      end
    end
  end

  class ActiveModelError
    def initialize(errors:, error_key:, error_index:)
      @errors = errors
      @key = error_key
      @index = error_index
    end

    def attributes
      @attributes ||= %i(id source detail code status).each_with_object({}) { |attr, h| h[attr] = send(attr) }
    end

    def id
      @id ||= SecureRandom.uuid
    end

    def source
      assoc, plural, * = key.to_s.match(/(.*)_id(s)?$/)&.captures
      path = if key == :base
               %w(data)
             elsif assoc.present?
               %w(data relationships) << (plural ? assoc.pluralize : assoc).to_s.camelize(:lower)
             else
               %w(data attributes) << key.to_s.camelize(:lower)
             end
      { pointer: '/' + path.join('/') }
    end

    def detail
      errors.messages[key][index]
    end

    def code
      error_detail.fetch(:error, :invalid)
    end

    def status
      http_status_code(error_status(code))
    end

    private

    attr_reader :errors, :key, :index

    def error_detail
      errors.details&.dig(key, index)
    end

    def error_status(error_code)
      case error_code
      when :not_found
        :not_found
      when :not_authenticated
        :unauthorized
      when :not_authorized
        :forbidden
      else
        :unprocessable_entity
      end
    end

    def http_status_code(status)
      if status.is_a?(Symbol)
        Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || DEFAULT_STATUS_CODE
      else
        status.to_i
      end
    end
  end

  def jsonapi_errors
    [].tap do |errors|
      keys.flat_map do |attr|
        messages[attr].each_with_index do |_message, idx|
          errors << Error.new(errors: self, error_key: attr, error_index: idx)
        end
      end
    end
  end
end
