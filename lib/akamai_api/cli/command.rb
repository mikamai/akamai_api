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
        else
          render_auth_info
          exit 1
        end
      end

      def render_auth_info
        puts <<-OUTPUT
No authentication config found. At the very least, specify auth credentials by creating a file in your home directory named `.akamai_api.yml` with the following content:"
  auth:
    - my_username
    - my_password
If using "ccu arl invalidate", your CCU api credentials should also be added:
  openapi:
    base_url:
    client_token:
    client_secret:
    access_token:
OUTPUT
      end
    end
  end
end
