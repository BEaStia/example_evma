require './config/environment'
Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  use Rack::Session::Cookie, :key => 'rack.session', :domain => '', :path => '/', :expire_after => 2592000, :secret => 'change_me', :old_secret => 'also_change_me'

  map '/statistics' do
    run AsyncSinatraApp.new
  end
  map '/' do
    run AsyncApp.new
  end
end

