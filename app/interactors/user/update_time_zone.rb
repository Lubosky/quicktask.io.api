class User::UpdateTimeZone < ApplicationInteractor
  string :time_zone, default: 'UTC'

  def execute
    transaction do
      unless user.update(given_attributes)
        errors.merge!(user.errors)
        rollback
      end
    end
    user
  end

  private

  def user
    @_user ||= current_user
  end
end
