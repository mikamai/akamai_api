module AkamaiApi
  module Cli
    class Ccu < Command
      desc 'cpcode', 'CP Code CCU actions'
      subcommand 'cpcode', CcuCpCode

      desc 'arl', 'ARL CCU actions'
      subcommand 'arl', CcuArl

      desc 'status [progress_uri]', 'Show the CCU queue status if no progress_uri is given, or show a CCU Purge request status if a progress uri is given'
      def status progress_uri = nil
        load_config
        res = AkamaiApi::Ccu.status progress_uri
        puts '------------'
        if res.is_a? AkamaiApi::Ccu::Status::Response
          puts AkamaiApi::Cli::Template.ccu_status_response res
        else
          puts AkamaiApi::Cli::Template.ccu_purge_status_response res
        end
        puts '------------'
      rescue AkamaiApi::Unauthorized
        puts 'Your login credentials are invalid.'
      end
    end
  end
end
