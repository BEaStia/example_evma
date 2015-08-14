require './app/BaseAsyncApp'
class AsyncApp
  include BaseAsyncApp
  AsyncResponse = [-1, {}, []].freeze

  def call(env)
    body = DeferrableBody.new
    headers = {'Content-Type' => 'text/plain'}
    if env['HTTP_COOKIE'].nil?
      Rack::Utils.set_cookie_header!(headers, "cookie_id", {:value => generate_key, :path => "/", :expires => Time.now+24*60*60})
    end
    ip = env['REMOTE_ADDR']
    #TODO: add getting ip and work with redis
    p env['HTTP_COOKIE'], ip

    EventMachine::next_tick { env['async.callback'].call [200, headers, body] }
    EventMachine::next_tick {
      body.call [@answer]
      body.succeed
    }
    AsyncResponse
  end
end