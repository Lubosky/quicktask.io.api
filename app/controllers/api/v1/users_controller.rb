class Api::V1::UsersController < Api::BaseController
  rescue_from(SignupToken::EmailInvalidError) { respond_with_error(:email_invalid, 400) }
  rescue_from(SignupToken::EmailRegisteredError) { respond_with_error(:email_already_registered, 409) }
  rescue_from(SignupToken::InvalidToken) { respond_with_error(:invalid_token, 401) }

  before_action :authenticate_user, except: [:create]

  deserializable_resource :user, only: [:create]

  def create
    run Onboarding::CreateUser do |action|
      if action.success?
        token = authenticate_resource(action.result)

        render json: token, status: :created
      else
        respond_with_errors(action.errors)
      end
    end
  end

  def me
    self.resource = current_user
    respond_with_resource
  end

  private

  def authenticate_resource(resource)
    AuthenticationToken.new(payload: resource.to_token_payload)
  end
end
