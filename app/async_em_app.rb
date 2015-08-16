require 'useragent'
require File.join('.','app','base_async_app')
require File.join('.','app','custom_request')
require 'geoip'

class AsyncApp
  include BaseAsyncApp
  AsyncResponse = [-1, {}, []].freeze

  def transform_cookie cookie
    request_cookie = Hash.new
    cookie.split(";").map{|it| request_cookie[it.split("=")[0].strip] = it.split("=")[1].strip}
    request_cookie
  end

  def call(env)
    body = DeferrableBody.new
    EventMachine::next_tick {
      request = CustomRequest.new env
      params = request.to_h
      p params
      find_by_sid_defer = AppEntry.find_by_sid(params['sid'])
      find_by_sid_defer.callback { |entries_result|
        if entries_result.num_tuples.zero?
          p "searching by ip"
          find_by_ip_defer = AppEntry.find_by_ip(params['ip'])
          find_by_ip_defer.callback {|ip_entries|
            if entries_result.num_tuples.zero?
              p "not found by ip"
              entry = AppEntry.new params
              save_defer = entry.save
              save_defer.callback {|result| }
              save_defer.errback{|e| p e }
            else
              p ip_entries
              #TODO: add some logic for ip here for detecting necessary user
              #<temporary>
              entry = AppEntry.new params
              save_defer = entry.save
              save_defer.callback {|result| }
              save_defer.errback{|e| p e }
              #</temporary>
            end
          }
          find_by_ip_defer.errback{|e| p e}
        else
          entries = entries_result.to_a
          if entries.size > 1
            p "collision succeeded!"
            p entries
          else
            p "update previous"
            entry = AppEntry.new entries.first
            entry.update params
          end
        end
      }
      find_by_sid_defer.errback {|e| p e }
      env['async.callback'].call [200, request.headers, body]
    }
    EventMachine::next_tick {
      body.call [@answer]
      body.succeed
    }
    AsyncResponse
  end
end