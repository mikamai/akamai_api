require "thor"
require "akamai_api/cli/CCU"
require "akamai_api/cli/Eccu"

module AkamaiApi::CLI
  class App < Thor
    desc 'ccu', 'CCU Interface'
    subcommand 'ccu', AkamaiApi::CLI::CCU::Base

    desc 'eccu', 'ECCU Interface'
    subcommand 'eccu', AkamaiApi::CLI::ECCU::Base

    def help *args
      puts
      puts "AkamaiApi is a command line utility to interact with Akamai CCU (Content Control Utility) and ECCU (Enhanced Content Control Utility) services."
      puts
      super
    end
  end
end
