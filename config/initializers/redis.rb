# set global variable for Redis use across the application
$redis = Redis::Namespace.new("facebook_app", :redis => Redis.new)