module AkamaiApi
  module Cli
    class Command < Thor
      class_option  :username, :type => :string, :aliases => '-u',
                    :desc => 'Username used to authenticate on Akamai Control Panel'
      class_option  :password, :type => :string, :aliases => '-p',
                    :desc => 'Password used to authenticate on Akamai Control Panel'

      no_tasks do
        def load_config
          config_file = File.expand_path '~/.akamai_api.yml'
          config = YAML::load_file(config_file).symbolize_keys
          if options[:username] && options[:password]
            config.merge! :auth => [options[:username], options[:password]]
          end
          if config[:auth].nil? || config[:auth].compact.blank?
            raise "#{config_file} does not exist or doesn't contain auth info and you didn't specify username and password options"
          end
          AkamaiApi.config.merge! config
        end
      end
    end
  end
end