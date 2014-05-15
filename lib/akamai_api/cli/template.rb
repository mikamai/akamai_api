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