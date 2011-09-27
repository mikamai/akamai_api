Bundler.require :default

root = File.expand_path(File.dirname(__FILE__) + '/..')
require File.join root, 'lib/akamai_api.rb'

Savon.configure do |config|
  config.log = false            # disable logging
  config.log_level = :info      # changing the log level
end
