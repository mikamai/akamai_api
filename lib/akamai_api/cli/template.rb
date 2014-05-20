module AkamaiApi
  module Cli
    module Template
      def self.eccu_request request
        res = ["* Code    : #{request.code}",
               "* Status  : #{request.status[:code]}"]
        res.last << " - #{request.status[:extended]}" if request.status[:extended].present?
        res << "            #{request.status[:update_date]}"
        res << "* Property: #{request.property[:name]} (#{request.property[:type]})"
        res << "            with exact match" if request.property[:exact_match]
        res << "* Notes   : #{request.notes}" if request.notes.present?
        res << "* Email   : #{request.email}" if request.email
        res << "* Uploaded by #{request.uploaded_by} on #{request.upload_date}"
        if request.file[:content].present?
          res << "* Content:"
          res << request.file[:content]
        end
        res.join "\n"
      end

      def self.cp_code cpcode
        "#{cpcode.code}\t#{cpcode.description}"
      end

      def self.ccu_status_response response
        [
          "Akamai CCU Queue Status",
          "\t* Result: #{response.code} - #{response.message}",
          "\t* Support ID: #{response.support_id}",
          "\t* Queue Length: #{response.queue_length}"
        ].join "\n"
      end

      def self.ccu_purge_status_response response
        if response.is_a? AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse
          ccu_purge_status_successful_response response
        else
          ccu_purge_status_not_found_response response
        end
      end

      def self.ccu_purge_status_successful_response response
        output = []
        if response.completed_at
          output << "Purge request has been successfully completed:"
        else
          output << "Purge request is currently enqueued:"
        end
        output.concat [
          "\t* Result: #{response.code} - #{response.status}",
          "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
          "\t* Submitted by: #{response.submitted_by} on #{response.submitted_at}"
        ]
        if response.completed_at
          output << "\t* Completed on: #{response.completed_at}"
        else
          output.concat [
            "\t* Estimated time: #{response.estimated_time} secs.",
            "\t* Queue length: #{response.queue_length}",
            "\t* Time to wait before next check: #{response.time_to_wait} secs."
          ]
        end
        output.join "\n"
      end

      def self.ccu_purge_status_not_found_response response
        [
          "No purge request found using #{response.progress_uri}:",
          "\t* Result: #{response.code} - #{response.message}",
          "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}",
          "\t* Time to wait before next check: #{response.time_to_wait} secs."
        ].join "\n"
      end

      def self.ccu_response response
        if response.code == 201
          ccu_successful_response response
        else
          ccu_error_response response
        end
      end

      def self.ccu_error_response response
        [
          "There was an error processing your request:",
          "\t* Result: #{response.code} - #{response.title} (#{response.message})",
          "\t* Described by: #{response.described_by}"
        ].join "\n"
      end

      def self.ccu_successful_response response
        result = [
          "Purge request successfully submitted:",
          "\t* Result: #{response.code} - #{response.message}",
          "\t* Purge ID: #{response.purge_id} | Support ID: #{response.support_id}"
        ]
        if response.time_to_wait
          result.concat [
            "\t* Estimated time: #{response.estimated_time} secs.",
            "\t* Progress URI: #{response.uri}",
            "\t* Time to wait before check: #{response.time_to_wait} secs.",
          ]
        end
        result.join "\n"
      end
    end
  end
end
