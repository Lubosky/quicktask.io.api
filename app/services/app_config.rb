class AppConfig
  CONFIG_FILES = %w()

  CONFIG_FILES.each do |resource|
    define_singleton_method(resource) do
      instance_variable_get(:"@#{resource}") ||
      instance_variable_set(:"@#{resource}", YAML.load_file(Rails.root.join('config', "#{resource}.yml")))
    end
  end
end
