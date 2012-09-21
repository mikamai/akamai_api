module AkamaiApi
  module Cli
    class Ccu < Command
      desc 'cpcode', 'CP Code CCU actions'
      subcommand 'cpcode', CcuCpCode

      desc 'url', 'URL CCU actions'
      subcommand 'url', CcuUrl
    end
  end
end