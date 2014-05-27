require "akamai_api/ccu/purge/request"

# @note Generally you don't want to directly use this module because some handy helpers are
#   already defined in the {AkamaiApi::Ccu} module.
#   But if you need to do it, read the following examples and check
#   the details of {Request} and {Response} classes.
#
# This module encapsulates classes aiming to purge resources using the Akamai CCU interface.
#
# @example Handling a purge response
#   begin
#     req = AkamaiApi::Ccu::Purge::Request.new
#     res = req.execute 'http://foo.bar/a.txt', 'http://www.foo.bar/a.txt'
#     if res.successful?
#       puts "Request #{res.purge_id} was successful (#{res.message})"
#     else
#       puts "Received #{res.title} (#{res.message}). Check details on #{res.described_by}"
#     end
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::Ccu::Purge
end
