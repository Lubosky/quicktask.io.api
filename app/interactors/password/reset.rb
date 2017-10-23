class Password::Reset < ApplicationInteractor
  string :email
  string :password
  string :password_confirmation
  string :token

  def execute
    user = retrieve_user_from_token
    raise PasswordResetToken::InvalidToken unless user

    email_verified = ActiveSupport::SecurityUtils.secure_compare(email, user.email)
    raise PasswordResetToken::InvalidToken unless email_verified

    unless user.reset_password(password, password_confirmation)
      errors.merge!(user.errors)
    end
  end

  private

  def retrieve_user_from_token
    @_user ||= PasswordResetToken.new(token).user
  end
end
