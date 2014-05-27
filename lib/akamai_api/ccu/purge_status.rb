require "akamai_api/ccu/purge_status/request"

# @note Generally you don't want to directly use this module because an handy helper is
#   already defined in the {AkamaiApi::Ccu} module.
#   But if you need to do it, read the following examples and check
#   the details of {Request}, {NotFoundResponse} and {SuccessfulResponse} classes.
#
# This module encapsulates the classes you need to check the status of purge request
# submitted using the Akamai CCU interface.
#
# @example Checking the status of a purge request
#   purge_id_or_progress_uri # => "/ccu/v2/purges/12345678-1234-5678-1234-123456789012"
#   begin
#     res = AkamaiApi::Ccu::PurgeStatus::Request.execute purge_id_or_progress_uri
#     if res.successful? # true for AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse
#       puts "Request status is '#{res.status}'"
#       puts "Request has been completed on '#{res.completed_at}'" if res.completed_at
#     else # AkamaiApi::Ccu::PurgeStatus::NotFoundResponse
#       puts "Request cannot be found (#{res.message})"
#     end
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::Ccu::PurgeStatus
end
