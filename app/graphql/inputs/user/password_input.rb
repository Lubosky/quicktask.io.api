module Inputs
  module User
    PasswordInput = GraphQL::InputObjectType.define do
      name 'UserPasswordInput'
      description ''

      argument :currentPassword, !types.String, as: :current_password
      argument :newPassword, !types.String, as: :new_password
      argument :newPasswordConfirmation, !types.String, as: :new_password_confirmation
    end
  end
end
