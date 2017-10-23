class Api::Oauth::GoogleController < Api::BaseController
  before_action :authenticate, only: [:create]

  def create
    render json: token, status: :created
  end

  private

  def authenticate
    unless code.present? && entity.present?
      head(:unauthorized)
    end
  end

  def token
    AuthenticationToken.new payload: entity.to_token_payload
  end

  def code
    permitted_params[:code]
  end

  def permitted_params
    params.permit(:code)
  end

  def entity
    @_entity ||= GoogleIdentity.new(code).authenticate
  end
end
