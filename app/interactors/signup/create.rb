class Signup::Create < ApplicationInteractor
  string :email
  string :first_name
  string :last_name
  string :password

  string :name
  string :slug, default: nil

  def execute
    transaction do
      unless user.save
        errors.merge!(user.errors)
        rollback
      end
      unless workspace.save
        errors.merge!(workspace.errors)
        rollback
      end
    end
    response = response_from_payload(user, workspace)
    response
  end

  private

  def user
    @_user ||= User.new(user_attributes)
  end

  def workspace
    @_workspace ||= Workspace.new(workspace_attributes)
  end

  def user_attributes
    attributes.slice(:email, :first_name, :last_name, :password)
  end

  def workspace_attributes
    attributes.slice(:name, :slug).tap do |attribute|
      attribute[:owner] = user
    end
  end

  def response_from_payload(user_entity, workspace_entity)
    user_from_payload(user_entity).tap do |attribute|
      attribute[:new_workspace] = workspace_from_payload(workspace_entity)
      attribute[:token] = authenticate_resource(user_entity).token
    end
  end

  def user_from_payload(payload)
    payload.slice(:id, :uuid, :email, :google_uid, :email_confirmed, :first_name, :last_name)
  end

  def workspace_from_payload(payload)
    payload.slice(:id, :uuid, :slug, :name, :status)
  end

  def authenticate_resource(resource)
    AuthenticationToken.new(payload: resource.to_token_payload)
  end
end
