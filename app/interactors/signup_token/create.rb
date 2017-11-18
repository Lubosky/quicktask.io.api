class SignupToken::Create < ApplicationInteractor
  string :email

  def execute
    raise SignupToken::EmailInvalidError unless EmailValidator.valid?(email)

    token = SignupToken.generate_for(normalized_email).to_s
    deliver_email(normalized_email, token)
  end

  private

  def normalized_email
    email.downcase
  end

  def deliver_email(normalized_email, token)
    mail = UserMailer.confirm_signup(email: normalized_email, token: token)
    mail.deliver_later
  end
end
