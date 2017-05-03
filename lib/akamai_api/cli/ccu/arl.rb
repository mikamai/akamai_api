require "akamai_api/ccu"
require "akamai_api/cli/command"
require "akamai_api/cli/ccu/purge_renderer"

module AkamaiApi::CLI::CCU
  class Arl < AkamaiApi::CLI::Command
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

        begin
          load_config
        rescue ArgumentError
          return
        end

        res = AkamaiApi::CCU.purge type, :arl, arls, :domain => options[:domain]
        puts PurgeRenderer.new(res).render

      rescue AkamaiApi::CCU::Error => e
        puts StatusRenderer.new($!).render_error
      rescue AkamaiApi::Unauthorized
        puts 'Your login credentials are invalid.'
      end
    end
  end
end
