module AkamaiApi::CLI::CCU
  class PurgeRenderer
    attr_reader :response

    def initialize response
      @response = response
    end

    def render
      [
        "----------",
        render_response,
        "----------"
      ].join "\n"
    end

    def render_response
      if response.code == 201
        render_successful_response
      else
        render_error_response
      end
    end

    def render_error_response
      [
        "There was an error processing your request:",
        "\t* Result: #{response.code} - #{response.title} (#{response.message})",
        "\t* Described by: #{response.described_by}"
      ]
    end

    def render_successful_response
      result = [
        "Purge request successfully submitted:",
        "\t* Result: #{response.code} - #{response.message}",
        "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}"
      ]

      result
    end
  end
end
