require './app/BaseAsyncApp'
class AsyncAppWithRackResponse
  include BaseAsyncApp

  def call(env)
    p env['HTTP_COOKIE']
    body = DeferrableBody.new
    response = Rack::Response.new body, 200, {'Content-Type'=>'image/gif'}
    response.body = [@answer]
    response.finish
    response
  end

end
