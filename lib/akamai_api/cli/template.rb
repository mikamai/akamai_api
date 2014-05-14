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
        result = [
          "#### Response Details ####",
          "* Purge ID: #{response.purge_id}",
          "* Support ID: #{response.support_id}",
          "* Result: #{response.code} - #{response.message}",
        ]
        if response.time_to_wait
          result.concat [
            "* Time to wait before check: #{response.time_to_wait} secs.",
            "* Estimated time: #{response.estimated_time} secs.",
            "* Progress URI: #{response.uri}"
          ]
        end
        result.join "\n"
      end
    end
  end
end