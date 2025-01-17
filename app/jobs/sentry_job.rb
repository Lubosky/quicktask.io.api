# frozen_string_literal: true

class SentryJob < ApplicationJob
  def perform(event)
    Raven.send_event(event.to_hash)
  end
end
