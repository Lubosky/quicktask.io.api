class Api::Auth::PasswordController < Api::BaseController
  rescue_from(PasswordResetToken::InvalidToken) { respond_with_error(:invalid_token, 401) }

  deserializable_resource :password, only: [:forgot, :reset]

  def forgot
    run Password::Forgot do
      head(:ok)
    end
  end

  def verify
    if retrieve_user_from_token
      head(:ok)
    else
      raise PasswordResetToken::InvalidToken
    end
  end

  def reset
    run Password::Reset do |action|
      if action.success?
        head(:ok)
      else
        respond_with_errors(action.errors)
      end
    end
  end

  private

  def retrieve_user_from_token
    @_user ||= PasswordResetToken.new(params[:token]).user
  end
end
