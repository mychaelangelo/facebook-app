# set global variable for Redis use across the application
REDIS = Redis::Namespace.new("facebook_app", :redis => Redis.new)