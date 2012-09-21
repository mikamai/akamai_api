module AkamaiApi
  module Cli
    class CcuCpCode < Command
      namespace 'ccu cpcode'

      desc 'list', 'Print the list of CP Codes'
      def list
        load_config
        AkamaiApi::CpCode.all.each do |cp_code|
          puts AkamaiApi::Cli::Template.cp_code(cp_code)
        end
      end

      desc 'remove CPCODE1 CPCODE2 ...', 'Purge CP Code(s) removing them from the cache'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :emails,   :type => :array,  :aliases => '-e',
                    :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def remove(*cpcodes)
        purge_action :remove, cpcodes
      end

      desc 'invalidate CPCODE1 CPCODE2 ...', 'Purge CP Code(s) marking their cache as expired'
      method_option :domain,   :type => :string, :aliases => '-d',
                    :banner => 'production|staging',
                    :desc => 'Optional argument used to specify the environment. Usually you will not need this option'
      method_option :emails,   :type => :array,  :aliases => '-e',
                    :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) used to send notification when the purge has been completed'
      def invalidate(*cpcodes)
        purge_action :invalidate, cpcodes
      end

      no_tasks do
        def purge_action type, cpcodes
          raise 'You should provide at least one valid CP Code' if cpcodes.blank?
          load_config
          res = AkamaiApi::Ccu.purge type, :cpcode, cpcodes, :domain => options[:domain], :email => options[:emails]
          puts '------------'
          puts AkamaiApi::Cli::Template.ccu_response res
          puts '------------'
        end
      end
    end
  end
end