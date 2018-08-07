Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type to rule them all.'

  field :authenticateUser, Mutations::AuthenticateUserMutation
  field :authenticateUserWithGoogle, Mutations::AuthenticateUserWithGoogleMutation

  field :updateLocale, Mutations::UpdateUserLocaleMutation
  field :updatePassword, Mutations::UpdateUserPasswordMutation
  field :updateTimeZone, Mutations::UpdateUserTimeZoneMutation

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

  field :createTasklist, Mutations::Team::Tasklist::CreateTasklistMutation
  field :updateTasklist, Mutations::Team::Tasklist::UpdateTasklistMutation
  field :updateTasklistPosition, Mutations::Team::Tasklist::UpdateTasklistPositionMutation

  field :createSingleTask, Mutations::Team::Task::CreateSingleTaskMutation
  field :createMultipleTasks, Mutations::Team::Task::CreateMultipleTasksMutation
  field :updateTask, Mutations::Team::Task::UpdateTaskMutation
  field :updateTaskPosition, Mutations::Team::Task::UpdateTaskPositionMutation
  field :updateTaskStatus, Mutations::Team::Task::UpdateTaskStatusMutation

  field :createTodo, Mutations::Team::Todo::CreateTodoMutation
  field :updateTodo, Mutations::Team::Todo::UpdateTodoMutation
  field :updateTodoPosition, Mutations::Team::Todo::UpdateTodoPositionMutation
  field :updateTodoStatus, Mutations::Team::Todo::UpdateTodoStatusMutation
  field :deleteTodo, Mutations::Team::Todo::DeleteTodoMutation

  field :updateTeamMember, Mutations::Team::TeamMember::UpdateTeamMemberMutation
  field :updateTeamMemberProfile, Mutations::Team::TeamMember::UpdateTeamMemberProfileMutation
end
