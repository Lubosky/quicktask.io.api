DEFAULT_REDIS_URL = 'redis://localhost:6379'.freeze

url = ENV.has_key?('REDIS_URL') ? ENV['REDIS_URL'] : DEFAULT_REDIS_URL
$redis = Redis.new(driver: :hiredis, url: url)
