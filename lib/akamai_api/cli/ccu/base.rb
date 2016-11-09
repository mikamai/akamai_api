require "akamai_api/ccu"
require "akamai_api/cli/command"
require "akamai_api/cli/ccu/cp_code"
require "akamai_api/cli/ccu/arl"
require "akamai_api/cli/ccu/status_renderer"

module AkamaiApi::CLI::CCU
  class Base < AkamaiApi::CLI::Command
    desc 'cpcode', 'CP Code CCU actions'
    subcommand 'cpcode', CpCode

    desc 'arl', 'ARL CCU actions'
    subcommand 'arl', Arl
  end
end
