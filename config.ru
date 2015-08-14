require 'rubygems'
require 'rack/async'
require 'eventmachine'
require 'base64'
require './lib/hack/lint'
require 'rack/auth/digest/md5'
require 'thin'
require './app/record'
require './app/RedisConnection'
require './app/AsyncApp'
require './app/AsyncAppWithRackResponse'
require './app/DeferrableBody'
Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  use Rack::Session::Cookie, :key => 'rack.session', :domain => '', :path => '/', :expire_after => 2592000, :secret => 'change_me', :old_secret => 'also_change_me'

  map '/s' do
    run AsyncAppWithRackResponse.new
  end
  map '/' do
    run AsyncApp.new
  end
end

