class HandOffToken::Validate < ApplicationInteractor
  string :token

  def execute
    raise HandOffToken::InvalidToken unless hand_off = retrieve_hand_off_from_token

    hand_off.increment!(:view_count)
    hand_off.update_columns(last_viewed_at: Time.current.to_formatted_s(:db))
    hand_off
  end

  private

  def retrieve_hand_off_from_token
    HandOffToken.new(token).hand_off
  end
end
