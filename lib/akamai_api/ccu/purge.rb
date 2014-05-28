require "akamai_api/ccu/purge/request"

# This module encapsulates classes aiming to purge resources using the Akamai CCU interface.
#
# @example Handling a purge response
#   begin
#     req = AkamaiApi::CCU::Purge::Request.new
#     res = req.execute 'http://foo.bar/a.txt', 'http://www.foo.bar/a.txt'
#     puts "Request #{res.purge_id} was successful (#{res.message})"
#   rescue AkamaiApi::CCU::Error
#     puts "Error #{$!.code} - #{$!.message}"
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::CCU::Purge
end
