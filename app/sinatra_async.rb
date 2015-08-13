require 'rubygems'
require 'sinatra/async'
require 'redis'
require 'json'
class Record
  @@counter = 0
  attr_accessor :session_id, :ip_address, :id, :node

  def initialize sid, ip, _id, _node
    session_id = sid
    ip_address = ip
    id = _id
    node = _node
  end

  def self.find_by_session_id sid
    JSON.load(AsyncSinatraApp.redis.hget "sessions", sid)
  end

  def self.find_by_ip ip
    JSON.load(AsyncSinatraApp.redis.hget "ips", ip)
  end

  def self.find_by_id _id
    JSON.load(AsyncSinatraApp.redis.hget "ids", _id)
  end

  def save
    AsyncSinatraApp.redis.hset "ids", id, self.to_json
    AsyncSinatraApp.redis.hset "sessions", session_id, id
    AsyncSinatraApp.redis.hset "ips", ip_address, id
  end

  def self.get_record sid, ip, _node
    result_id = find_by_session_id(sid) || find_by_ip(ip) #TODO: check creation completely
    found_record = find_by_id result_id
    if found_record.nil?
      record = Record.new(sid, ip, @@counter, _node)
      @@counter += 1
      record.save
      AsyncSinatraApp.redis.incr "records_count"
    else
      if _node == found_record
        session_id = sid
        ip_address = id
        node = _node
        AsyncSinatraApp.redis.hset "missed", id, "#{found_record.node}_#{_node}"
        AsyncSinatraApp.redis.incr "missed_records_count"
      end
    end

  end
end

class AsyncSinatraApp < Sinatra::Base
  register Sinatra::Async
  use Rack::Session::Cookie, :key => 'rack.session', :domain => 'localhost', :path => '/', :expire_after => 2592000, :secret => 'fuck_it_all'

  enable :show_exceptions

  before do
    content_type 'image/gif'
  end

  def initialize
    super
    @@redis = Redis.new(:db=>1)
  end

  def self.redis
    @@redis
  end


  aget '/' do
    ip = request.ip
    addr = env['host']
    sid = env['rack.session']['session_id']
    record = Record.get_record(sid, ip, addr)

    p record
    body Answer
  end
end
