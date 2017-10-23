class PermittedParams < Struct.new(:params)
  MODELS = %w()

  MODELS.each do |kind|
    define_method(kind) do
      permitted_attributes = send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
    alias_method :"api_#{kind}", kind.to_sym
  end
  alias :read_attribute_for_serialization :send
end
