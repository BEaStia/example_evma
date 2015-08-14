require 'rubygems'
require 'sinatra/async'
require 'redis'
require 'json'
require 'msgpack'

class Record
  attr_accessor :session_id, :ip_address, :id, :node

  def initialize sid, ip, _id, _node
    @session_id = sid
    @ip_address = ip
    @id = _id
    @node = _node
  end

  def self.find_by_session_id sid
    JSON.load(AsyncSinatraApp.redis.hget "sessions", sid)
  end

  def self.find_by_ip ip
    JSON.load(AsyncSinatraApp.redis.hget "ips", ip)
  end

  def self.find_by_id _id
    json = AsyncSinatraApp.redis.hget "ids", _id
    unless json.nil?
      from_json(json)
    end
  end

  def to_json
    {'session_id'=> session_id, 'ip_address' => ip_address, 'id' => id, 'node'=>node}.to_json
  end

  def self.from_json json
    attrs = JSON.load(json)
    Record.new(attrs['session_id'], attrs['ip_address'], attrs['id'], attrs['node'])
  end

  def save
    AsyncSinatraApp.redis.hset "ids", @id, self.to_json
    AsyncSinatraApp.redis.hset "sessions", @session_id, id
    AsyncSinatraApp.redis.hset "ips", @ip_address, id
  end

  def self.inc
    AsyncSinatraApp.redis.incr "records_count"
  end

  def self.counter
    AsyncSinatraApp.redis.get "records_count"
  end

  def self.get_record sid, ip, _node
    result_id = find_by_session_id(sid) || find_by_ip(ip) #TODO: check creation completely
    found_record = find_by_id result_id
    if found_record.nil?
      record = Record.new(sid, ip, counter, _node)
      record.save
      inc
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
  #use Rack::Session::Cookie, :key => 'rack.session', :domain => '', :path => '/', :expire_after => 2592000, :secret => 'fuck_it_all'
  set :sessions => true

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

  def generate_key
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  end


  aget '/' do
    ip = request.ip
    addr = request.env['SERVER_NAME']
    #session['ip'] = ip
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
