require "akamai_api/ccu"
require "akamai_api/cli/command"
require "akamai_api/cli/ccu/cp_code"
require "akamai_api/cli/ccu/arl"
require "akamai_api/cli/ccu/status_renderer"

module AkamaiApi::Cli::Ccu
  class Base < AkamaiApi::Cli::Command
    desc 'cpcode', 'CP Code CCU actions'
    subcommand 'cpcode', CpCode

    desc 'arl', 'ARL CCU actions'
    subcommand 'arl', Arl

    desc 'status [progress_uri]', 'Show the CCU queue status if no progress_uri is given, or show a CCU Purge request status if a progress uri is given'
    def status progress_uri = nil
      load_config
      response = AkamaiApi::Ccu.status progress_uri
      puts StatusRenderer.new(response).render
    rescue AkamaiApi::Unauthorized
      puts 'Your login credentials are invalid.'
    end
  end
end
