namespace :redis do
  desc "Clear the Redis cache"
  task clear: :environment do
    redis = Redis.new
    redis.flushdb
    puts "Redis cache cleared."
  end
end
