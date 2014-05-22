module AkamaiApi::Eccu
  class DestroyRequest < BaseRequest
    def execute
      with_soap_error_handling do
        response = client_call :delete, message: request_body.to_s
        response.body[:delete_response][:success]
      end
    end

    def request_body
      SoapBody.new.tap do |body|
        body.integer :fileId, code
      end
    end
  end
end
