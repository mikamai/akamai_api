module AkamaiApi::Cli::Ccu
  class StatusRenderer
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def render
      res = response.is_a?(AkamaiApi::Ccu::Status::Response) ? render_status : render_purge_status
      [
        '----------',
        res,
        '----------'
      ].join "\n"
    end

    def render_status
      [
        "Akamai CCU Queue Status",
        "\t* Result: #{response.code} - #{response.message}",
        "\t* Support ID: #{response.support_id}",
        "\t* Queue Length: #{response.queue_length}"
      ].join "\n"
    end

    def render_purge_status
      if response.is_a? AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse
        render_successful_purge_status
      else
        render_not_found_purge_status
      end
    end

    def render_successful_purge_status
      output = [
        successful_purge_status_description,
        "\t* Result: #{response.code} - #{response.status}",
        "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
        "\t* Submitted by: #{response.submitted_by} on #{response.submitted_at}"
      ]
      if response.completed_at
        output << "\t* Completed on: #{response.completed_at}"
      else
        output << "\t* Estimated time: #{response.estimated_time} secs."
        output << "\t* Queue length: #{response.queue_length}"
        output << "\t* Time to wait before next check: #{response.time_to_wait} secs."
      end
      output.join "\n"
    end

    def successful_purge_status_description
      if response.completed_at
        "Purge request has been successfully completed:"
      else
        "Purge request is currently enqueued:"
      end
    end

    def render_not_found_purge_status
      [
        "No purge request found using #{response.progress_uri}:",
        "\t* Result: #{response.code} - #{response.message}",
        "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
        "\t* Time to wait before next check: #{response.time_to_wait} secs."
      ].join "\n"
    end
  end
end
