require 'ipaddress'
require 'user_agent'
class CustomRequest

  attr_accessor :headers, :node, :ua, :country, :sid, :ip
  def initialize env
    @headers = {'Content-Type' => 'text/plain'}
    set_key = false
    if env['HTTP_COOKIE'].nil?
      key = generate_key
      set_key = true
    else
      transformed_cookie = transform_cookie(env['HTTP_COOKIE'])
      if transformed_cookie.has_key?('cookie_id')
        key = transformed_cookie['cookie_id']
      else
        key = generate_key
        set_key = true
      end
    end

    if set_key
      Rack::Utils.set_cookie_header!(@headers, 'cookie_id', {:value => key, :path => "/", :expires => Time.now+24*60*60*30})
    end
    @sid = key

    if IPAddress.valid?(env['SERVER_NAME'])
      @node = env['SERVER_NAME']
    else
      @node = Resolv.getaddress(env['SERVER_NAME'])
    end

    @ua = UserAgent.parse(env['HTTP_USER_AGENT']).to_h.stringify_keys

    @country = GeoIP.new("./lib/GeoLiteCity.dat").country("217.175.38.170").country_code3

    if IPAddress.valid?(env['REMOTE_ADDR'])
      @ip = env['REMOTE_ADDR']
    else
      p "shit happened"
    end
  end

  def generate_key
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def transform_cookie cookie
    cookie.split(";").inject({}){|hash, it| hash[it.split("=")[0].strip] = it.split("=")[1].strip; hash}
  end

  def to_h
    {'sid'=>@sid, 'ip'=>@ip, 'node'=>@node, 'browser_version'=>@ua['version'].join('.'), 'browser'=>@ua['browser'], 'platform'=>@ua['platform'], 'os'=>@ua['os'], 'mobile'=>(@ua['mobile'] ? 't' : 'f'), 'bot'=>@ua['bot'] ? 't' : 'f', 'country'=>@country}
  end
end