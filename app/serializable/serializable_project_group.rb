class SerializableProjectGroup < SerializableBase
  type :project_group

  attribute :workspace_id
  attribute :client_id

  attribute :name
end
