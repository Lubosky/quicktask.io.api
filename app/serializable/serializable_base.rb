class SerializableBase < JSONAPI::Serializable::Resource
  extend JSONAPI::Serializable::Resource::KeyFormat

  key_format ->(key) { key.to_s.camelize(:lower) }

  id { @object.uuid }
end
