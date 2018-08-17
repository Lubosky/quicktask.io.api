class Api::V1::HandOffTokensController < Api::BaseController
  rescue_from(HandOffToken::ExpiredToken) { respond_with_error(:token_expired, 401) }
  rescue_from(HandOff::HandOffExpired) { respond_with_error(:hand_off_expired, 401) }

  deserializable_resource :hand_off_token, only: [:create]

  def verify
    run HandOffToken::Validate, params do |action|
      if action.success?
        respond_with_result(action: action)
      else
        respond_with_errors(action.errors)
      end
    end
  end
end
