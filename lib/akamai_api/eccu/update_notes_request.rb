require "akamai_api/eccu/base_edit_request"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateNotesRequest < BaseEditRequest
    def execute notes
      with_soap_error_handling do
        client_call(:set_notes, message: request_body(notes).to_s)[:success]
      end
    end

    def request_body notes
      super do |block|
        block.string  :notes,  notes
      end
    end
  end
end
