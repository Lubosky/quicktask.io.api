module Identity
  def authenticate_for(entity_class)
    getter_name = "current_#{entity_class.to_s.parameterize.underscore}"
    define_current_entity_getter(entity_class, getter_name)
    public_send(getter_name)
  end

  def revoke_for(entity_class)
    revoke_current_entity_token(entity_class)
  end

  private

  def authentication_token
    params[:token] || token_from_request_headers
  end

  def authenticate_entity(entity_name)
    if authentication_token
      entity_class = entity_name.camelize.constantize
      send(:authenticate_for, entity_class)
    end
  end

  def revoke_entity(entity_name)
    if authentication_token
      entity_class = entity_name.camelize.constantize
      send(:revoke_for, entity_class)
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
      unauthorized_entity unless authenticate_entity(entity_name)
    when 'current'
      authenticate_entity(entity_name)
    when 'revoke'
      revoke_entity(entity_name)
    else
      super
    end
  end

  def revoke_current_entity_token(entity_class)
    begin
      AuthenticationToken.new(token: authentication_token).revoke_for(entity_class)
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      nil
    end
  end

  def define_current_entity_getter(entity_class, getter_name)
    unless self.respond_to?(getter_name)
      memoization_variable_name = "@_#{getter_name}"
      self.class.send(:define_method, getter_name) do
        unless instance_variable_defined?(memoization_variable_name)
          current =
            begin
              AuthenticationToken.new(token: authentication_token).entity_for(entity_class)
            rescue ActiveRecord::RecordNotFound, JWT::DecodeError
              nil
            end
          instance_variable_set(memoization_variable_name, current)
        end
        instance_variable_get(memoization_variable_name)
      end
    end
  end
end
