class Api::Auth::TokenController < Api::BaseController
  before_action :authenticate, only: [:create]
  before_action :revoke_token, only: [:destroy]

  def create
    render json: token, status: :created
  end

  def destroy; end

  private

  def authenticate
    unless entity.present? && entity.authenticate(permitted_params[:password])
      head(:unauthorized)
    end
  end

  def token
    AuthenticationToken.new payload: entity.to_token_payload
  end

  def permitted_params
    params.permit([:email, :password])
  end

  def entity
    @_entity ||= User.find_by_normalized_email(permitted_params[:email])
  end
end
