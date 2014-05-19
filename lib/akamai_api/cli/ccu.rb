module AkamaiApi
  module Cli
    class Ccu < Command
      desc 'cpcode', 'CP Code CCU actions'
      subcommand 'cpcode', CcuCpCode

      desc 'arl', 'ARL CCU actions'
      subcommand 'arl', CcuArl

      desc 'status', 'Show the CCU Status'
      def status
        load_config
        res = AkamaiApi::Ccu.status
        puts '------------'
        puts AkamaiApi::Cli::Template.ccu_status_response res
        puts '------------'
      rescue AkamaiApi::Ccu::Unauthorized
        puts 'Your login credentials are invalid'
      end
    end
  end
end
