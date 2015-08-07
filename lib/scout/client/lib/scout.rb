$:.unshift File.dirname(__FILE__)

require 'set'
require 'pathname'
require 'yaml'
require 'hashie'
require 'oauth'
require 'oauth/consumer'
require 'nokogiri'
require 'faster_xml_simple'
require 'logger'
require 'zlib'
require 'fantasy_football_nerd'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'

module Scout
  class << self
    attr_accessor :root, :config_dir, :data_dir, :db_dir, :log_dir, :lib_dir
    attr_accessor :api_config, :database
  end
  
  self.root       = Pathname.new(File.expand_path(File.dirname(__FILE__))) + '..'
  self.config_dir = root + 'config'
  self.data_dir   = root + 'data'
  self.lib_dir    = root + 'lib'
  self.db_dir     = data_dir + 'db'
  self.log_dir    = root + 'logs'
  self.database   = db_dir + 'data.db'
    
  FANTASY_FOOTBALL_NERD_API_KEY = 'besx7cbqcwqm'  
  FFNerd.api_key = FANTASY_FOOTBALL_NERD_API_KEY
end

require Scout.config_dir + 'database'

$:.unshift Scout.root
Dir[Scout.lib_dir + 'scout/**/*.rb'].sort.each do |library_file|
  require library_file
end

Scout.api_config = Scout::ApiConfig.new(Scout.config_dir + 'api.yml')