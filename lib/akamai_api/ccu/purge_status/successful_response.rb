require "akamai_api/ccu/purge_status/response"

module AkamaiApi::Ccu::PurgeStatus
  # This class represents a successful response and details a purge request status
  class SuccessfulResponse < Response
    # Estimated time (in seconds) for the operation to be completed calculated when
    # the request was submitted
    # @return [Fixnum] estimated time (in seconds) for the operation to be completed
    def estimated_time
      raw['originalEstimatedSeconds']
    end

    alias_method :original_estimated_seconds, :estimated_time

    # Number of jobs in queue when the request was submitted
    # @return [Fixnum] number of jobs in queue when the request was submitted
    def queue_length
      raw['originalQueueLength']
    end

    alias_method :original_queue_length, :queue_length

    # The time the request was completed
    # @return [Time] the time the request was completed
    # @return [nil] when the request has not been completed (= its status isn't 'Done')
    def completed_at
      raw['completionTime'] && Time.iso8601(raw['completionTime'])
    end

    alias_method :completion_time, :completed_at

    # The request author name
    # @return [String] the request author name
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
