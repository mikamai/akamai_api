module AkamaiApi
  module Cli
    class CcuArl < Command
      namespace 'ccu arl'

      desc 'remove http://john.com/a.txt http://www.smith.com/b.txt ...', 'Purge ARL(s) removing them from the cache'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def remove(*arls)
        purge_action :remove, arls
      end

      desc 'invalidate http://john.com/a.txt http://www.smith.com/b.txt ...', 'Purge ARL(s) marking their cache as expired'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def invalidate(*arls)
        purge_action :invalidate, arls
      end

      no_tasks do
        def purge_action type, arls
          raise 'You should provide at least one valid URL' if arls.blank?
          load_config
          res = AkamaiApi::Ccu.purge type, :arl, arls, :domain => options[:domain]
          puts '------------'
          puts AkamaiApi::Cli::Template.ccu_response res
          puts '------------'
        rescue AkamaiApi::Ccu::Unauthorized
          puts 'Your login credentials are invalid.'
        end
      end
    end
  end
end
