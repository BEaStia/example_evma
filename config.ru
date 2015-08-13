require './app'
require 'base64'
require 'thin'

# app = proc do |env|
#   body = [Answer]
#   p env
#   [200, { 'Content-Type' => 'image/gif' }, body]
# end
#
# run app
#
# Answer = Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
#
# use Rack::Session::Cookie, key => 'rack.session',
#     :domain => 'localhost',
#     :path => '/',
#     :expire_after => 2592000,
#     :secret => 'fuck_it_all'
#
# class App
#   def answer
#     Answer
#   end
#
#   def callback env
#     Rack::Session::Cookie.new(application, { :cookie => Rack::Session::Cookie::Identity.new })
#   end
# end

module AsyncApp
  Answer = Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
end
require './app/sinatra_async'
AsyncSinatraApp.include AsyncApp
run AsyncSinatraApp
