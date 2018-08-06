class UserPolicy < ApplicationPolicy
  def update?
    @user.is_a?(User)
  end
end
