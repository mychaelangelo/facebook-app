# set global variable for Redis use across the application

#REDIS = Redis::Namespace.new("facebook_app", :redis => Redis.new)


username = ENV["REDIS_USR"]
password = ENV["REDIS_PW"]

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)