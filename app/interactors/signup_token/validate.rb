class SignupToken::Validate < ApplicationInteractor
  string :token

  def execute
    raise SignupToken::InvalidToken unless email = retrieve_email_from_token

    user = guest_with_email(email)
  end

  private

  def guest_with_email(email)
    Guest.new(email: email)
  end

  def retrieve_email_from_token
    SignupToken.new(token).email
  end
end
