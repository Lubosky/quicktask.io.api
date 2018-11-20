Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type to rule them all.'

  field :authenticateUser, Mutations::AuthenticateUserMutation
  field :authenticateUserWithGoogle, Mutations::AuthenticateUserWithGoogleMutation

  field :updateLocale, Mutations::UpdateUserLocaleMutation
  field :updatePassword, Mutations::UpdateUserPasswordMutation
  field :updateTimeZone, Mutations::UpdateUserTimeZoneMutation

  field :updateWorkspaceAccountSettings, Mutations::WorkspaceAccount::UpdateWorkspaceAccountSettingsMutation

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
  field :duplicateProject, Mutations::Team::Project::DuplicateProjectMutation

  field :createTasklist, Mutations::Team::Tasklist::CreateTasklistMutation
  field :updateTasklist, Mutations::Team::Tasklist::UpdateTasklistMutation
  field :updateTasklistPosition, Mutations::Team::Tasklist::UpdateTasklistPositionMutation
  field :duplicateTasklist, Mutations::Team::Tasklist::DuplicateTasklistMutation

  field :createSingleTask, Mutations::Team::Task::CreateSingleTaskMutation
  field :createMultipleTasks, Mutations::Team::Task::CreateMultipleTasksMutation
  field :updateTask, Mutations::Team::Task::UpdateTaskMutation
  field :updateTaskPosition, Mutations::Team::Task::UpdateTaskPositionMutation
  field :updateTaskStatus, Mutations::Team::Task::UpdateTaskStatusMutation
  field :duplicateTask, Mutations::Team::Task::DuplicateTaskMutation

  field :createTodo, Mutations::Team::Todo::CreateTodoMutation
  field :updateTodo, Mutations::Team::Todo::UpdateTodoMutation
  field :updateTodoPosition, Mutations::Team::Todo::UpdateTodoPositionMutation
  field :updateTodoStatus, Mutations::Team::Todo::UpdateTodoStatusMutation
  field :deleteTodo, Mutations::Team::Todo::DeleteTodoMutation

  field :createProjectTemplate, Mutations::Team::ProjectTemplate::CreateProjectTemplateMutation
  field :updateProjectTemplate, Mutations::Team::ProjectTemplate::UpdateProjectTemplateMutation
  field :deleteProjectTemplate, Mutations::Team::ProjectTemplate::DeleteProjectTemplateMutation

  field :createTemplateTasklist, Mutations::Team::Tasklist::CreateTemplateTasklistMutation
  field :updateTemplateTasklistPosition, Mutations::Team::Tasklist::UpdateTasklistPositionMutation
  field :duplicateTemplateTasklist, Mutations::Team::Tasklist::DuplicateTemplateTasklistMutation

  field :createSingleTemplateTask, Mutations::Team::Task::CreateSingleTemplateTaskMutation
  field :createMultipleTemplateTasks, Mutations::Team::Task::CreateMultipleTemplateTasksMutation
  field :updateTemplateTask, Mutations::Team::Task::UpdateTemplateTaskMutation
  field :updateTemplateTaskPosition, Mutations::Team::Task::UpdateTemplateTaskPositionMutation
  field :duplicateTemplateTask, Mutations::Team::Task::DuplicateTaskMutation

  field :createSingleTag, Mutations::Team::Tag::CreateSingleTagMutation
  field :createMultipleTags, Mutations::Team::Tag::CreateMultipleTagsMutation
  field :updateTag, Mutations::Team::Tag::UpdateTagMutation
  field :addTag, Mutations::Team::Tag::AddTagMutation
  field :removeTag, Mutations::Team::Tag::RemoveTagMutation
  field :deleteTag, Mutations::Team::Tag::DeleteTagMutation

  field :createHandOff, Mutations::Team::HandOff::CreateHandOffMutation
  field :updateHandOffStatus, Mutations::Team::HandOff::UpdateHandOffStatusMutation

  field :updateTeamMember, Mutations::Team::TeamMember::UpdateTeamMemberMutation
  field :updateTeamMemberProfile, Mutations::Team::TeamMember::UpdateTeamMemberProfileMutation
end
