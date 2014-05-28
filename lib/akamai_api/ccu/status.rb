require "akamai_api/ccu/status/request"

# This module encapsulates the classes you need to check the status of the Akamai CCU queue,
#
# @example Checking the status of the Akamai CCU queue
#   begin
#     res = AkamaiApi::CCU::Status::Request.execute
#     puts "There are #{res.queue_length} jobs in queue"
#   rescue AkamaiApi::Unauthorized
#     puts "Invalid login"
#   end
module AkamaiApi::CCU::Status
end
