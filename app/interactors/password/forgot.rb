class Password::Forgot < ApplicationInteractor
  string :email

  def execute
    if user = find_user_for_password_change
      token = PasswordResetToken.generate_for(user).to_s
      deliver_email(user, token)
    end
  end

  private

  def deliver_email(user, token)
    mail = UserMailer.password_change_request(user: user, token: token)
    mail.deliver_later
  end

  def find_user_for_password_change
    @_user ||= User.find_by_normalized_email(email)
  end
end
