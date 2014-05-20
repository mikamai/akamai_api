require File.expand_path '../response', __FILE__

module AkamaiApi::Ccu::PurgeStatus
  class SuccessfulResponse < Response
    def estimated_time
      raw_body['originalEstimatedSeconds']
    end

    def queue_length
      raw_body['originalQueueLength']
    end

    def completed_at
      raw_body['completionTime'] && Time.iso8601(raw_body['completionTime'])
    end

    def submitted_by
      raw_body['submittedBy']
    end

    def submitted_at
      raw_body['submissionTime'] && Time.iso8601(raw_body['submissionTime'])
    end
  end
end
