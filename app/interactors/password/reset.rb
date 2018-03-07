class Password::Reset < ApplicationInteractor
  string :password
  string :password_confirmation
  string :token

  def execute
    user = retrieve_user_from_token
    raise PasswordResetToken::InvalidToken unless user

    unless user.reset_password(password, password_confirmation)
      errors.merge!(user.errors)
    end
  end

  private

  def retrieve_user_from_token
    @_user ||= PasswordResetToken.new(token).user
  end
end
