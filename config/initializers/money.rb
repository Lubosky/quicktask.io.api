require 'money/bank/google_currency'

Money.infinite_precision = true
Money::Bank::GoogleCurrency.ttl_in_seconds = 86400

MoneyRails.configure do |config|
  config.default_bank = Money::Bank::GoogleCurrency.new
  config.no_cents_if_whole = false
end
