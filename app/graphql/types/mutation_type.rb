Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type to rule them all.'

  field :authenticateUser, Mutations::AuthenticateUserMutation
  field :authenticateUserWithGoogle, Mutations::AuthenticateUserWithGoogleMutation

  field :updateWorkspaceUserSettings, Mutations::WorkspaceUser::UpdateWorkspaceUserSettingsMutation

  field :createProject, Mutations::Team::Project::CreateProjectMutation
  field :updateProject, Mutations::Team::Project::UpdateProjectMutation
  field :deleteProject, Mutations::Team::Project::DeleteProjectMutation
  field :updateProjectStatus, Mutations::Team::Project::UpdateProjectStatusMutation
end
