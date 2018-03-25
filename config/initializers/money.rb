require 'money_oxr/bank'

Money.infinite_precision = true

MoneyRails.configure do |config|
  config.default_bank = MoneyOXR::Bank.new(
    app_id: ENV.fetch('OXR_API_KEY', 'oxr_api_key'),
    cache_path: 'config/xr.json',
    max_age: 86400
  )
  config.no_cents_if_whole = false
end
