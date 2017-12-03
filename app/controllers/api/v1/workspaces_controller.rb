class Api::V1::WorkspacesController < Api::BaseController
  before_action :authenticate_user
  before_action :ensure_workspace, except: [:create]
  before_action :ensure_workspace_user, except: [:index, :create]

  deserializable_resource :workspace, only: [:create]

  def create
    run Onboarding::CreateWorkspace do |action|
      respond_with_result(action: action)
    end
  end

  def show
    self.resource = current_workspace
    respond_with_resource
  end

  def accessible_records
    collection = policy_scope(Workspace)
    collection = apply_scopes(collection)
  end
end
