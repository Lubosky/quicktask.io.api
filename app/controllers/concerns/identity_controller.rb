module IdentityController
  extend ActiveSupport::Concern

  included {}

  def authenticate_for
    define_current_user
    public_send(:current_user)
  end

  def revoke_for
    revoke_current_token
  end

  def ensure_for(entity_class)
    getter_name = :"current_#{entity_class.to_s.parameterize.underscore}"
    define_current_workspace
    public_send(getter_name)
  end

  private

  def authentication_token
    params[:token] || token_from_request_headers
  end

  def authentication_token?
    !!authentication_token
  end

  def workspace_identifier
    params[:workspace_identifier]
  end

  def workspace_identifier?
    !!workspace_identifier
  end

  def authenticate_entity
    if authentication_token?
      send(:authenticate_for)
    end
  end

  def ensure_entity(entity_name)
    if workspace_identifier?
      entity_class = entity_name.camelize.constantize
      send(:ensure_for, entity_class)
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

  def method_missing(method, *args)
    prefix, entity_name = method.to_s.split('_', 2)
    case prefix
    when 'authenticate'
      unauthorized_entity unless authenticate_entity
    when 'current'
      authenticate_entity
    when 'ensure'
      unauthorized_entity unless ensure_entity(entity_name)
    when 'revoke'
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
              Workspace.find_by!(slug: workspace_identifier.downcase)
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
end
