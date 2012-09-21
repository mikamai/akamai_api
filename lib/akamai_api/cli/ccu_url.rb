module AkamaiApi
  module Cli
    class CcuUrl < Command
      namespace 'ccu url'

      desc 'remove http://john.com/a.txt http://www.smith.com/b.txt ...', 'Purge URL(s) removing them from the cache'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :emails,   :type => :array,  :aliases => '-e',
                    :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def remove(*urls)
        purge_action :remove, urls
      end

      desc 'invalidate http://john.com/a.txt http://www.smith.com/b.txt ...', 'Purge URL(s) marking their cache as expired'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :emails,   :type => :array,  :aliases => '-e',
                    :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def invalidate(*urls)
        purge_action :invalidate, urls
      end

      no_tasks do
        def purge_action type, urls
          raise 'You should provide at least one valid URL' if urls.blank?
          load_config
          res = AkamaiApi::Ccu.purge type, :arl, cpcodes, :domain => options[:domain], :email => options[:emails]
          puts '------------'
          puts AkamaiApi::Cli::Template.ccu_response res
          puts '------------'
        end
      end
    end
  end
end