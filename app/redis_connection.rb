require 'em-hiredis'
class RedisConnection
  def self.redis
    @redis = EM::Hiredis.connect("redis://111@localhost:6379/1") if @redis.nil?
    @redis
  end
end