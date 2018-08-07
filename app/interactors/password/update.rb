class Password::Update < ApplicationInteractor
  ::PasswordMismatchError = Class.new(StandardError)

  string :current_password
  string :new_password
  string :new_password_confirmation

  def execute
    raise ::PasswordMismatchError unless user && password_matches

    unless user.reset_password(new_password, new_password_confirmation)
      errors.merge!(user.errors)
    end
    user
  end

  private

  def user
    @_user ||= current_user
  end

  def password_matches
    user.password_matches?(current_password)
  end
end
