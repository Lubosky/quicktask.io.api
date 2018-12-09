class Api::V1::SignupTokensController < Api::BaseController
  rescue_from(SignupToken::EmailInvalidError) { respond_with_error(:email_invalid, 400) }
  rescue_from(SignupToken::EmailRegisteredError) { respond_with_error(:email_already_registered, 409) }
  rescue_from(SignupToken::InvalidToken) { respond_with_error(:invalid_token, 401) }

  deserializable_resource :signup_token, only: [:create]

  def create
    run SignupToken::Create do |action|
      if action.success?
        render(:created)
      else
        respond_with_errors(action.errors)
      end
    end
  end

  def verify
    run SignupToken::Validate, params do |action|
      if action.success?
        respond_with_result(action: action)
      else
        respond_with_errors(action.errors)
      end
    end
  end

  private

  def resource_serializer
    GuestSerializer
  end
end
