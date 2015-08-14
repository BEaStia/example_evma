require 'rubygems'
require 'sinatra/async'
require 'redis'
require 'json'
require 'msgpack'
require './app/record'
class RedisConnection
	def self.redis
		AsyncSinatraApp.redis
	end
end


class AsyncSinatraApp < Sinatra::Base
  set :server, :thin
  register Sinatra::Async
  set :sessions => true
  enable :show_exceptions

  before do
    content_type 'image/gif'
  end

  def initialize
    super
#    @@redis = Redis.new(:db=>1, :password=>"111")
#    @@redis.set "ping", "pong"
#    p @@redis.get "ping"
  end

  def self.redis
    @@redis
  end

  def generate_key
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  end

  aget '/' do
    ip = request.ip
    addr = request.env['SERVER_NAME']
    
    p session
    if request.cookies['my_cookie'].nil?
      response.set_cookie("my_cookie", :value => generate_key, :domain => FALSE, :path => "/", :expires => Time.now + (60*60*24*30))
    end
    cookie = request.cookies["my_cookie"]
    p cookie
    sid = cookie
    p "#{sid}, #{ip}, #{addr}"
    record = Record.get_record(sid, ip, addr)

    p record
    body Answer
  end

end
