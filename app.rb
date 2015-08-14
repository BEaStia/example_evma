require './app/record'
require 'base64'
require 'http_router'

class Router < HttpRouter

  ANSWER = Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")

  def call(env, &callback)
    p "call"
    super
  end
end