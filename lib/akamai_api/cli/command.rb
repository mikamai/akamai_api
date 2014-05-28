require "thor"
require "active_support"
require "active_support/core_ext/hash"

module AkamaiApi::CLI
  class Command < Thor
    class_option  :username, :type => :string, :aliases => '-u',
                  :desc => 'Username used to authenticate on Akamai Control Panel'
    class_option  :password, :type => :string, :aliases => '-p',
                  :desc => 'Password used to authenticate on Akamai Control Panel'

    no_tasks do
      def load_config
        load_config_from_file
        load_config_from_env
        load_config_from_options
        if AkamaiApi.auth_empty?
          render_auth_info
          exit 1
        end
      end

      def config_file
        File.expand_path '~/.akamai_api.yml'
      end

      def load_config_from_file
        if File.exists?(config_file)
          AkamaiApi.config.merge! YAML::load_file(config_file).symbolize_keys
        end
      end

      def load_config_from_options
        AkamaiApi.config[:auth].tap do |auth|
          auth[0] = options.fetch 'username', auth[0]
          auth[1] = options.fetch 'password', auth[1]
        end
      end

      def load_config_from_env
        AkamaiApi.config[:auth].tap do |auth|
          auth[0] = ENV.fetch 'AKAMAI_USERNAME', auth[0]
          auth[1] = ENV.fetch 'AKAMAI_PASSWORD', auth[1]
        end
      end

      def render_auth_info
        puts <<-OUTPUT
No authentication config found. You can specify auth credentials with one of the following methods:"

* Creating a file in your home directory named `.akamai_api.yml` with the following content:"
  auth:"
    - my_username"
    - my_password"

* Using the environment variables AKAMAI_USERNAME and AKAMAI_PASSWORD. E.g:"
  AKAMAI_USERNAME=my_username AKAMAI_PASSWORD=my_password akamai_api ECCU last_request"

* Passing username and password options from command line. E.g.:"
 akamai_api ECCU last_request -u my_username -p my_password"
OUTPUT
      end
    end
  end
end
