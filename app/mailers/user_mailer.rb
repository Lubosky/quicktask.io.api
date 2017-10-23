class UserMailer < BaseMailer
  helper :application
  helper :email

  def password_change_request(user:, token:)
    @user = user
    @link = build_url(:password_change_request, token: token)

    send_single_email to: @user.email,
                      subject_key: :'email.password_change_request.subject',
                      locale: locale_for(@user)
  end
end
