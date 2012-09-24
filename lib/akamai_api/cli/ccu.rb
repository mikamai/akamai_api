module AkamaiApi
  module Cli
    class Ccu < Command
      desc 'cpcode', 'CP Code CCU actions'
      subcommand 'cpcode', CcuCpCode

      desc 'arl', 'ARL CCU actions'
      subcommand 'arl', CcuArl
    end
  end
end