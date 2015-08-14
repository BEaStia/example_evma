
class Record
  attr_accessor :session_id, :ip_address, :id_obj, :node

  def initialize sid, ip, _id, _node
    @session_id = sid
    @ip_address = ip
    @id_obj = _id
    @node = _node
  end

  def self.find_by_session_id sid
    JSON.load(RedisConnection.redis.hget "sessions", sid)
  end

  def self.find_by_ip ip
    JSON.load(RedisConnection.redis.hget "ips", ip)
  end

  def self.find_by_id _id
    json = RedisConnection.redis.hget "ids", _id
    unless json.nil?
      from_json(json)
    end
  end

  def to_json
    {'session_id'=> session_id, 'ip_address' => ip_address, 'id' => id_obj, 'node'=>node}.to_json
  end

  def self.from_json json
    attrs = JSON.load(json)
    Record.new(attrs['session_id'], attrs['ip_address'], attrs['id'], attrs['node'])
  end

  def save
    RedisConnection.redis.hset "ids", id_obj, self.to_json
    RedisConnection.redis.hset "sessions", session_id, id_obj
    RedisConnection.redis.hset "ips", ip_address, id_obj
  end

  def self.inc
    RedisConnection.redis.incr "records_count"
  end

  def self.counter
    RedisConnection.redis.get "records_count"
  end

  def self.get_record sid, ip, _node
    result_id = find_by_session_id(sid) || find_by_ip(ip) #TODO: check creation completely
    found_record = find_by_id result_id
    if found_record.nil?
      p "record not found"
      record = Record.new(sid, ip, counter.to_i, _node)
      record.save
      inc
      record
    else
      if _node != found_record.node
        RedisConnection.redis.hset "missed", found_record.id_obj, "#{found_record.node}_#{_node}"
        RedisConnection.redis.incr "missed_records_count"	
      end
      found_record.session_id = sid
      found_record.ip_address = ip
      found_record.node = _node
      found_record.save
      found_record
    end
      
  end
end