class AppEntry


  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  attr_accessor :id, :sid, :ip, :node, :browser, :browser_version, :os, :platform, :mobile, :bot, :country

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def initialize params
    (params).each{|key, value|
      set_attribute key, value
    }
  end

  def update attrs
    updated_counts = attrs.inject(0){|count, arr|
      key = arr[0]
      value = arr[1]
      if send(key.to_sym) != value
        if key.to_sym == :node
          query = DB.query_defer("INSERT INTO errors(sid, ip, old_node, new_node) VALUES('#{sid}', '#{ip}', '#{node}', '#{value}'")
          query.callback{|result| }
          query.errback{|result| }
        end
        set_attribute key, value
        count += 1
      end
      count
    }
    save! if updated_counts > 0
  end

  def set_attribute key, value
    send("#{key}=".to_sym, value)
  end

  def save
    if id.nil?
      query = "INSERT INTO entries (sid, ip, node, browser, browser_version, os, platform, mobile, bot, country) VALUES ('#{sid}', '#{ip}', '#{node}', '#{browser}', '#{browser_version}', '#{os}', '#{platform}', '#{mobile}', '#{bot}', '#{country}')"
    else
      query = "UPDATE entries SET sid = '#{sid}', ip = '#{ip}', node = '#{node}', browser = '#{browser}', browser_version = '#{browser_version}', os = '#{os}', platform = '#{platform}', mobile = '#{mobile}', bot = '#{bot}', country = '#{country}' WHERE id = #{id}"
    end
    DB.query_defer(query)
  end

  def save!
    save_defer = save
    save_defer.callback {|e| p "entry ##{id} saved!"}
    save_defer.errback{|e| p e}
  end

  def self.method_missing(methId, arg)
    if methId.to_s.include?("find_by_")
      column = methId.to_s.gsub("find_by_", "")
      if self.attributes.include?(column.to_sym)
        DB.query_defer("SELECT * FROM entries WHERE #{column} =  '#{arg}'")
      else
        super
      end
    else
      super
    end
  end

end