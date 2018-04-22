Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type to rule them all.'

  field :authenticateUser, Mutations::AuthenticateUserMutation
  field :authenticateUserWithGoogle, Mutations::AuthenticateUserWithGoogleMutation

  field :updateWorkspaceUserSettings, Mutations::WorkspaceUser::UpdateWorkspaceUserSettingsMutation

  field :createClient, Mutations::Team::Client::CreateClientMutation
  field :updateClient, Mutations::Team::Client::UpdateClientMutation
  field :deleteClient, Mutations::Team::Client::DeleteClientMutation

  field :createContractor, Mutations::Team::Contractor::CreateContractorMutation
  field :updateContractor, Mutations::Team::Contractor::UpdateContractorMutation
  field :deleteContractor, Mutations::Team::Contractor::DeleteContractorMutation

  field :createProject, Mutations::Team::Project::CreateProjectMutation
  field :updateProject, Mutations::Team::Project::UpdateProjectMutation
  field :deleteProject, Mutations::Team::Project::DeleteProjectMutation
  field :updateProjectStatus, Mutations::Team::Project::UpdateProjectStatusMutation
end
