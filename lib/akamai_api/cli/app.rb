module AkamaiApi
  module Cli
    class App < Thor
      desc 'ccu', 'CCU Interface'
      subcommand 'ccu', AkamaiApi::Cli::Ccu

      desc 'eccu', 'ECCU Interface'
      subcommand 'eccu', AkamaiApi::Cli::Eccu

      def help *args
        puts
        puts "AkamaiApi is a command line utility to interact with Akamai CCU (Content Control Utility) and ECCU (Enhanced Content Control Utility) services."
        puts
        super
      end
    end
  end
end