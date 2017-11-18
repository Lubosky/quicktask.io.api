class Onboarding::CreateUser < ApplicationInteractor
  string :email
  string :first_name
  string :last_name
  string :password
  string :signup_token

  def execute
    raise SignupToken::InvalidToken unless email == email_from_token

    transaction do
      unless user.save
        errors.merge!(user.errors)
        rollback
      end
    end
    user
  end

  private

  def user
    @user ||= User.new(user_attributes)
  end

  def user_attributes
    attributes.slice(:email, :first_name, :last_name, :password)
  end

  def email_from_token
    SignupToken.new(signup_token).email
  end
end
