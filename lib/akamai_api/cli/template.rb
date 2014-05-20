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
        output = ["Status has been successfully received:"]
        rows = if response.is_a? AkamaiApi::Ccu::StatusResponse
                 output.concat [
                   "\t* Result: #{response.code} - #{response.message}",
                   "\t* Queue Length: #{response.queue_length}",
                   "\t* Support ID: #{response.support_id}"
                 ]
               elsif response.is_a? AkamaiApi::Ccu::PurgeStatusResponse
                 if response.submitted_at
                   output.concat [
                     "\t* Result: #{response.code} - #{response.status}",
                     "\t* Purge ID: #{response.purge_id}",
                     "\t* Support ID: #{response.support_id}",
                     "\t* Submitted by '#{response.submitted_by}' on #{response.submitted_at}"
                   ]
                   if response.completed_at
                     output.concat [
                       "\t* Completed on: #{response.completed_at}"
                     ]
                   else
                     output.concat [
                       "\t* Estimated time: #{response.estimated_time} secs.",
                       "\t* Queue length: #{response.queue_length}",
                       "\t* Time to wait before next check: #{response.time_to_wait} secs."
                     ]
                   end
                 else
                   output.concat [
                     "\t* Result: #{response.code} - #{response.message}",
                     "\t* Purge ID: #{response.purge_id}",
                     "\t* Support ID: #{response.support_id}",
                     "\t* Time to wait before next check: #{response.time_to_wait} secs."
                   ]
                 end
               end
        rows.join "\n"
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
          "Request has been submitted successfully:",
          "\t* Result: #{response.code} - #{response.message}",
          "\t* Purge ID: #{response.purge_id}",
          "\t* Support ID: #{response.support_id}"
        ]
        if response.time_to_wait
          result.concat [
            "\t* Time to wait before check: #{response.time_to_wait} secs.",
            "\t* Estimated time: #{response.estimated_time} secs.",
            "\t* Progress URI: #{response.uri}"
          ]
        end
        result.join "\n"
      end
    end
  end
end
