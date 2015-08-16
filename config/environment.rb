require 'rubygems'
require 'rack/async'
require 'eventmachine'
require 'base64'
path = File.join(".", "lib", "hack", "*.rb")
Dir.glob(path).each{|x| require x}
require 'rack/auth/digest/md5'
require 'thin'
Dir.glob(File.join(".", "app", "*.rb")).each{|x| require x}
require 'pg'
require 'yaml'
require 'pg/em'
RACK_ENV = ENV['RACK_ENV'] || 'development'
database_config = YAML.load(File.open("./config/database.yml").read)
DB = PG::EM::Client.new database_config[RACK_ENV].symbolize_keys