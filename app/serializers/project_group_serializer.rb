class ProjectGroupSerializer < BaseSerializer
  set_id    :id
  set_type  :project_group

  attributes :workspace_id,
             :client_id,
             :name
end
