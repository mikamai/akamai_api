module AkamaiApi::Ccu
  class PurgeStatusResponse
    attr_reader :raw_body

    def initialize(body)
      @raw_body = body
    end

    def estimated_time
      raw_body['originalEstimatedSeconds']
    end

    def progress_uri
      raw_body['progressUri']
    end

    def queue_length
      raw_body['originalQueueLength']
    end

    def purge_id
      raw_body['purgeId']
    end

    def support_id
      raw_body['supportId']
    end

    def code
      raw_body['httpStatus']
    end

    def completed_at
      raw_body['completionTime'] && Time.iso8601(raw_body['completionTime'])
    end

    def submitted_by
      raw_body['submittedBy']
    end

    def status
      raw_body['purgeStatus']
    end

    def message
      raw_body['detail']
    end

    def submitted_at
      raw_body['submissionTime'] && Time.iso8601(raw_body['submissionTime'])
    end

    def time_to_wait
      raw_body['pingAfterSeconds']
    end
  end
end
