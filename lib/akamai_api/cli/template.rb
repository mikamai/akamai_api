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
        res = ['#### Response Details ####',
               "* Request ID: #{response.session_id}",
               "* Code: #{response.code} (#{response.status})",
               "* Message: #{response.message}"]
        res << "* Estimate Time: #{response.estimated_time} secs.;" if response.estimated_time > 0
        res << "* Error caused by: #{response.uri};" if res.uri
        res.join "\n"
      end
    end
  end
end