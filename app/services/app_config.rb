class AppConfig
  CONFIG_FILES = %w(
    languages
  )

  CONFIG_FILES.each do |resource|
    define_singleton_method(resource) do
      instance_variable_get(:"@#{resource}") ||
      instance_variable_set(:"@#{resource}", Oj.load_file(Rails.root.join('config', "#{resource}.json").to_s, symbol_keys: true))
    end
  end
end
