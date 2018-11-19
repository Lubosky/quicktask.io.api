module IdentityController
  extend ActiveSupport::Concern

  included {}

  def authenticate_for
    define_current_user
    public_send(:current_user)
  end

  def ensure_for
    define_current_workspace
    public_send(:current_workspace)
  end

  def ensure_workspace_for
    define_current_account
    public_send(:current_account)
  end

  def revoke_for
    revoke_current_token
  end

  private

  def authentication_token
    params[:token] || token_from_request_headers
  end

  def authentication_token?
    !!authentication_token
  end

  def workspace_identifier
    params[:identifier] ||
    params[:workspace_identifier] ||
    graphql_variables[:workspaceId]
  end

  def workspace_identifier?
    !!workspace_identifier
  end

  def authenticate_entity
    if authentication_token?
      send(:authenticate_for)
    end
  end

  def ensure_entity
    if workspace_identifier?
      send(:ensure_for)
    end
  end

  def ensure_workspace_entity
    if current_user && current_workspace
      send(:ensure_workspace_for)
    end
  end

  def revoke_entity
    if authentication_token?
      send(:revoke_for)
    end
  end

  def unauthorized_entity
    head(:unauthorized)
  end

  def token_from_request_headers
    unless request.headers['Authorization'].nil?
      request.headers['Authorization'].split.last
    end
  end

  def graphql_variables
    if params[:variables]
      params[:variables]
    else
      {}
    end
  end

  def method_missing(method, *args)
    case method.to_sym
    when :authenticate_user
      unauthorized_entity unless authenticate_entity
    when :ensure_workspace
      unauthorized_entity unless ensure_entity
    when :ensure_workspace_account
      unauthorized_entity unless ensure_workspace_entity
    when :current_user
      authenticate_entity
    when :current_workspace
      ensure_entity
    when :current_account
      ensure_workspace_entity
    when :revoke_token
      revoke_entity
    else
      super
    end
  end

  def define_current_user
    unless self.respond_to?(:current_user)
      memoization_variable_name = :@_current_user
      self.class.send(:define_method, :current_user) do
        unless instance_variable_defined?(memoization_variable_name)
          current =
            begin
              AuthenticationToken.new(token: authentication_token).entity_for(User)
            rescue ActiveRecord::RecordNotFound, JWT::DecodeError
              nil
            end
          instance_variable_set(memoization_variable_name, current)
        end
        instance_variable_get(memoization_variable_name)
      end
    end
  end

  def define_current_workspace
    unless self.respond_to?(:current_workspace)
      memoization_variable_name = :@_current_workspace
      self.class.send(:define_method, :current_workspace) do
        unless instance_variable_defined?(memoization_variable_name)
          current =
            begin
              Workspace.find_by!(id: workspace_identifier)
            rescue ActiveRecord::RecordNotFound
              nil
            end
          instance_variable_set(memoization_variable_name, current)
        end
        instance_variable_get(memoization_variable_name)
      end
    end
  end

  def define_current_account
    unless self.respond_to?(:current_account)
      memoization_variable_name = :@_current_account
      self.class.send(:define_method, :current_account) do
        unless instance_variable_defined?(memoization_variable_name)
          current =
            begin
              set_current_account
            rescue ActiveRecord::RecordNotFound
              nil
            end
          instance_variable_set(memoization_variable_name, current)
        end
        instance_variable_get(memoization_variable_name)
      end
    end
  end

  def revoke_current_token
    begin
      AuthenticationToken.new(token: authentication_token).revoke_for(Token)
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      nil
    end
  end

  def set_current_account
    if account_type = graphql_variables[:accountType]
      set_current_account_for(account_type)
    else
      current_workspace.accounts.find_by(user: current_user)
    end
  end

  def set_current_account_for(identifier)
    case identifier.underscore.to_sym
    when :team_member
      current_workspace.collaborating_team_members.find_by(user: current_user)
    when :contractor
      current_workspace.collaborating_contractors.find_by(user: current_user)
    when :client_contact
      current_workspace.collaborating_clients.find_by(user: current_user)
    else
      nil
    end
  end
end
