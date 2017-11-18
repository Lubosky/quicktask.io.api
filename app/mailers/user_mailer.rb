class UserMailer < BaseMailer
  helper :application
  helper :email

  def confirm_signup(email:, token:)
    @link = build_url(:confirm_signup, token: token)
    send_single_email to: email,
                      subject_key: :'email.confirm_signup.subject',
                      locale: I18n.locale
  end

  def password_change_request(user:, token:)
    @user = user
    @link = build_url(:password_change_request, token: token)

    send_single_email to: @user.email,
                      subject_key: :'email.password_change_request.subject',
                      locale: locale_for(@user)
  end
end
