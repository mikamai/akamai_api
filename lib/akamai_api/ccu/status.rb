require "akamai_api/ccu/status/request"

# @note Generally you don't want to directly use this module because an handy helper is
#   already defined in the {AkamaiApi::Ccu} module.
#   But if you need to do it, read the following examples and check
#   the details of {Request} and {Response} classes.
#
# This module encapsulates classes you need to check the status of the Akamai CCU queue,
#
# @example Checking the status of the Akamai CCU queue
#   begin
#     res = AkamaiApi::Ccu::Status::Request.execute
#     puts "There are #{res.queue_length} jobs in queue"
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::Ccu::Status
end
