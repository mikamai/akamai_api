require "thor"

module AkamaiApi
  module Cli
    class Command < Thor
      class_option  :username, :type => :string, :aliases => '-u',
                    :desc => 'Username used to authenticate on Akamai Control Panel'
      class_option  :password, :type => :string, :aliases => '-p',
                    :desc => 'Password used to authenticate on Akamai Control Panel'

      no_tasks do
        def load_config
          config = {}
          config_file = File.expand_path '~/.akamai_api.yml'
          if File::exists?( config_file )
            config = YAML::load_file(config_file).symbolize_keys
          end
          if ENV['AKAMAI_USERNAME'] && ENV['AKAMAI_PASSWORD']
            config.merge! :auth => [ENV['AKAMAI_USERNAME'], ENV['AKAMAI_PASSWORD']]
          end
          if options[:username] && options[:password]
            config.merge! :auth => [options[:username], options[:password]]
          end
          if config[:auth].nil? || config[:auth].compact.blank?
            raise "#{config_file} does not exist OR doesn't contain auth info OR you didn't export environment variables OR you didn't specify username and password on the command line"
          end
          AkamaiApi.config.merge! config
        end
      end
    end
  end
end
