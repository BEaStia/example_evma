
module BaseAsyncApp
  attr_accessor :redis

  def initialize
    @answer = Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
  end

  def generate_key
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  end
end