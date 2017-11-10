class Api::Auth::SignupsController < Api::BaseController
  deserializable_resource :signup, only: [:create]

  def create
    run Signup::Create do |action|
      if action.success?
        respond_with_user(action.result)
      else
        respond_with_errors(action.errors)
      end
    end
  end

  private

  def respond_with_user(resource)
    render json: { user: resource }, status: :created
  end
end
