require "savon"

require "akamai_api/eccu/not_found"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateNotesRequest
    attr_reader :code

    def initialize code
      @code = code
    end

    def execute notes
      response = client.call :set_notes, message: request_body(notes).to_s
      response.body[:set_notes_response][:success]
    rescue Savon::HTTPError => e
      e = ::AkamaiApi::Unauthorized if e.http.code == 401
      raise e
    rescue Savon::SOAPFault => e
      e = ::AkamaiApi::Eccu::NotFound if e.to_hash[:fault][:faultstring] =~ /fileId .* does not exist/
      raise e
    end

    def request_body notes
      SoapBody.new.tap do |block|
        block.integer :fileId, code
        block.string  :notes,  notes
      end
    end

    private

    def client
      AkamaiApi::Eccu.client
    end
  end
end
