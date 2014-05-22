require "savon"

require "akamai_api/eccu/base_request"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateNotesRequest < BaseRequest
    attr_reader :code

    def initialize code
      @code = code
    end

    def execute notes
      with_soap_error_handling do
        response = client_call :set_notes, message: request_body(notes).to_s
        response.body[:set_notes_response][:success]
      end
    end

    def request_body notes
      SoapBody.new.tap do |block|
        block.integer :fileId, code
        block.string  :notes,  notes
      end
    end
  end
end
