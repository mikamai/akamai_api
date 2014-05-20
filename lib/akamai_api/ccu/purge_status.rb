module AkamaiApi::Ccu::PurgeStatus
  def self.build_response parsed_response
    response_class = parsed_response['submittedBy'] ? SuccessfulResponse : NotFoundResponse
    response_class.new parsed_response
  end
end

require File.expand_path '../purge_status/request', __FILE__
require File.expand_path '../purge_status/successful_response', __FILE__
require File.expand_path '../purge_status/not_found_response', __FILE__
