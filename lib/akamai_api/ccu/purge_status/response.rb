require "akamai_api/ccu/base_response"

module AkamaiApi::CCU::PurgeStatus
  # This class represents a successful response and details a purge request status
  class Response < AkamaiApi::CCU::BaseResponse
    # URI to use to ask the status of the Purge Request
    # @return [String] URI to use to ask the status
    def uri
      raw['progressUri']
    end
    alias_method :progress_uri, :uri

    # Purge Request identifier
    # @return [String] Purge Request identifier
    def purge_id
      raw['purgeId']
    end

    # Status of the purge request
    # @return ['In-Progress'] when the request is in progress
    # @return ['Done'] when the request has been completed
    # @return ['Unknown']
    def status
      raw['purgeStatus']
    end
    alias_method :purge_status, :status

    # @return [Fixnum] Suggested time to wait (in seconds) before asking the status again
    def time_to_wait
      raw['pingAfterSeconds']
    end
    alias_method :ping_after_seconds, :time_to_wait

    # @return [Fixnum] Estimated time (in seconds) for the operation to be completed, calculated when the request was submitted
    def original_estimated_time
      raw['originalEstimatedSeconds']
    end
    alias_method :original_estimated_seconds, :original_estimated_time

    # @return [Fixnum] Number of jobs in queue, calculated when the request was submitted
    def original_queue_length
      raw['originalQueueLength']
    end

    # The time the request was completed
    # @return [Time] the time the request was completed
    # @return [nil] when the request has not been completed (= its status isn't 'Done')
    def completed_at
      raw['completionTime'] && Time.iso8601(raw['completionTime'])
    end
    alias_method :completion_time, :completed_at

    # @return [String] The request author name
    def submitted_by
      raw['submittedBy']
    end

    # The time the request was accepted
    # @return [Time] the time the request was accepted
    # @return [nil] when the request is still not accepted (= its status is neither 'Done' nor 'In-Progress')
    def submitted_at
      raw['submissionTime'] && Time.iso8601(raw['submissionTime'])
    end
    alias_method :submission_time, :submitted_at
  end
end
