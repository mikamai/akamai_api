require "akamai_api/ccu/purge_status/request"

# @note Generally you don't want to directly use this module because an handy helper is
#   already defined in the {AkamaiApi::CCU} module.
#   But if you need to do it, read the following examples and check
#   the details of {Request} and {Response} classes.
#
# This module encapsulates the classes you need to check the status of purge request
# submitted using the Akamai CCU interface.
#
# @example Checking the status of a purge request
#   purge_id_or_progress_uri # => "/CCU/v2/purges/12345678-1234-5678-1234-123456789012"
#   begin
#     res = AkamaiApi::CCU::PurgeStatus::Request.execute purge_id_or_progress_uri
#     puts "Request status is '#{res.status}'"
#     puts "Request has been completed on '#{res.completed_at}'" if res.completed_at
#   rescue AkamaiApi::CCU::Error
#     puts "Error #{$!.code} - #{$!.message}"
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::CCU::PurgeStatus
end
