require 'useragent'
require File.join('.','app','base_async_app')
require 'geoip'

class AsyncApp
  include BaseAsyncApp
  AsyncResponse = [-1, {}, []].freeze

  def transform_cookie cookie
    request_cookie = Hash.new
    cookie.split(";").map{|it| request_cookie[it.split("=")[0].strip] = it.split("=")[1].strip}
    request_cookie
  end

  def get_cookie env
    headers = {'Content-Type' => 'text/plain'}
    if env['HTTP_COOKIE'].nil? #create new key
      key = generate_key
      Rack::Utils.set_cookie_header!(headers, 'cookie_id', {:value => key, :path => "/", :expires => Time.now+24*60*60*30})
    else
      transformed_cookie = transform_cookie(env['HTTP_COOKIE'])
      if transformed_cookie.has_key?('cookie_id') #if has cookie_id
        key = transformed_cookie['cookie_id']
      else
        key = generate_key
        Rack::Utils.set_cookie_header!(headers, 'cookie_id', {:value => key, :path => "/", :expires => Time.now+24*60*60*30})
      end
    end
    [key, headers]
  end

  def get_node env
    env['SERVER_NAME']
  end

  def get_ua env
    UserAgent.parse(env['HTTP_USER_AGENT']).to_h.stringify_keys
  end

  def get_country env
    GeoIP.new("./lib/GeoLiteCity.dat").country("217.175.38.170").country_code3
  end

  def get_entry_params env
    ip = env['REMOTE_ADDR']
    key, headers = get_cookie env
    ua = get_ua env
    country = get_country env
    [headers,{'sid'=>key, 'ip'=>ip, 'node'=>env['SERVER_NAME'], 'browser_version'=>ua['version'].join('.'), 'browser'=>ua['browser'], 'platform'=>ua['platform'], 'os'=>ua['os'], 'mobile'=>(ua['mobile'] ? 't' : 'f'), 'bot'=>ua['bot'] ? 't' : 'f', 'country'=>country}]
  end

  def call(env)
    body = DeferrableBody.new
    EventMachine::next_tick {
      headers, params = get_entry_params env
      find_by_sid_defer = AppEntry.find_by_sid(params['sid'])
      find_by_sid_defer.callback { |entries_result|
        if entries_result.num_tuples.zero?
          entry = AppEntry.new params
          save_defer = entry.save
          save_defer.callback {|result|

          }
          save_defer.errback{|e|
            p e
          }
        else
          entries = entries_result.to_a
          if entries.size > 1
            p "collision succeeded!"
            p entries
          else
            entry = AppEntry.new entries.first
            entry.update params
          end
        end
      }
      find_by_sid_defer.errback {|e|
        p e
      }
      env['async.callback'].call [200, headers, body]
    }
    EventMachine::next_tick {
      body.call [@answer]
      body.succeed
    }
    AsyncResponse
  end
end