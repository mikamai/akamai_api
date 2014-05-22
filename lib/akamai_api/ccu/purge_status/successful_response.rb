require "akamai_api/ccu/purge_status/response"

module AkamaiApi::Ccu::PurgeStatus
  class SuccessfulResponse < Response
    def estimated_time
      raw['originalEstimatedSeconds']
    end

    def queue_length
      raw['originalQueueLength']
    end

    def completed_at
      raw['completionTime'] && Time.iso8601(raw['completionTime'])
    end

    def submitted_by
      raw['submittedBy']
    end

    def submitted_at
      raw['submissionTime'] && Time.iso8601(raw['submissionTime'])
    end
  end
end
