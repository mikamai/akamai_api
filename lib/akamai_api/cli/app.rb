require "thor"
require "akamai_api/cli/ccu"
require "akamai_api/cli/eccu"

module AkamaiApi
  module Cli
    class App < Thor
      desc 'ccu', 'CCU Interface'
      subcommand 'ccu', AkamaiApi::Cli::Ccu::Base

      desc 'eccu', 'ECCU Interface'
      subcommand 'eccu', AkamaiApi::Cli::Eccu::Base

      def help *args
        puts
        puts "AkamaiApi is a command line utility to interact with Akamai CCU (Content Control Utility) and ECCU (Enhanced Content Control Utility) services."
        puts
        super
      end
    end
  end
end
