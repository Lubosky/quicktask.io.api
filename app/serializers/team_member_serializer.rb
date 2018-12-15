class TeamMemberSerializer < BaseSerializer
  set_id    :id
  set_type  :team_member

  attributes :first_name,
             :last_name,
             :email,
             :title,
             :workspace_id
end
