class User::Create < ApplicationInteractor
  string :email
  string :first_name
  string :last_name
  string :password

  def execute
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
    @user ||= User.new(attributes)
  end
end
