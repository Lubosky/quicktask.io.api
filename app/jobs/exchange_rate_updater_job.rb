# frozen_string_literal: true

class ExchangeRateUpdaterJob
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  DEFAULT_EXCHANGE_RATE = '1.0'.freeze

  def perform(workspace_id, default_currency, currency_codes = nil)
    workspace = Workspace.find(workspace_id)
    currencies = workspace.supported_currencies
    currencies = currencies.where(code: currency_codes) if currency_codes

    Workspace.transaction do
      currencies.find_each do |currency|
        exchange_rate = retrieve_exchange_rate(from: currency.code, to: default_currency)
        currency.update_attribute(:exchange_rate, exchange_rate)
      end
    end
  end

  private

  def retrieve_exchange_rate(from:, to:)
    Money.default_bank.get_rate(from, to)
  rescue Money::Bank::UnknownRate
    DEFAULT_EXCHANGE_RATE
  end
end
