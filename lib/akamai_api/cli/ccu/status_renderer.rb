require "akamai_api/ccu/status/response"
require "akamai_api/ccu/purge_status/successful_response"

module AkamaiApi::CLI::Ccu
  class StatusRenderer
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def render
      res = response.is_a?(AkamaiApi::Ccu::Status::Response) ? queue_status : purge_status
      [
        '----------',
        res,
        '----------'
      ].join "\n"
    end

    def queue_status
      [
        "Akamai CCU Queue Status",
        "\t* Result: #{response.code} - #{response.message}",
        "\t* Support ID: #{response.support_id}",
        "\t* Queue Length: #{response.queue_length}"
      ]
    end

    def purge_status
      if response.is_a? AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse
        successful_purge
      else
        not_found_purge
      end
    end

    def successful_purge
      output = [
        purge_description,
        "\t* Result: #{response.code} - #{response.status}",
        "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
        "\t* Submitted by: #{response.submitted_by} on #{response.submitted_at}"
      ]
      output.concat response.completed_at ? successful_completed_purge : successful_pending_purge
    end

    def purge_description
      if response.completed_at
        "Purge request has been successfully completed:"
      else
        "Purge request is currently enqueued:"
      end
    end

    def not_found_purge
      [
        "No purge request found using #{response.progress_uri}:",
        "\t* Result: #{response.code} - #{response.message}",
        "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
        "\t* Time to wait before next check: #{response.time_to_wait} secs."
      ]
    end

    def successful_completed_purge
      ["\t* Completed on: #{response.completed_at}"]
    end

    def successful_pending_purge
      [
        "\t* Estimated time: #{response.estimated_time} secs.",
        "\t* Queue length: #{response.queue_length}",
        "\t* Time to wait before next check: #{response.time_to_wait} secs.",
      ]
    end
  end
end
