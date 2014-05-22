require "savon"

require "akamai_api/unauthorized"
require "akamai_api/eccu/not_found"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateEmailRequest
    attr_reader :code

    def initialize code
      @code = code
    end

    def execute email
      response = client.call :set_status_change_email, :message => request_body(email).to_s
      response.body[:set_status_change_email_response][:success]
    rescue Savon::HTTPError => e
      e = ::AkamaiApi::Unauthorized if e.http.code == 401
      raise e
    rescue Savon::SOAPFault => e
      e = ::AkamaiApi::Eccu::NotFound if e.to_hash[:fault][:faultstring] =~ /fileId .* does not exist/
      raise e
    end

    def request_body email
      SoapBody.new.tap do |body|
        body.integer :fileId, code
        body.string  :statusChangeEmail, email
      end
    end

    private

    def client
      AkamaiApi::Eccu.client
    end
  end
end
