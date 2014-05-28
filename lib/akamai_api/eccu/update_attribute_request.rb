require "akamai_api/eccu/base_edit_request"

module AkamaiApi::ECCU
  # {UpdateAttributeRequest} is a generic request class that can be used to update an attribute of an ECCU request.
  #
  # This class is used to update the {AkamaiApi::ECCURequest#notes} or the {AkamaiApi::ECCURequest#email} attributes
  #
  # @example
  #   begin
  #     res = AkamaiApi::ECCU::UpdateAttributeRequest.execute 12345, 'notes', 'my new notes'
  #     puts "Request completed: #{res}"
  #   rescue AkamaiApi::ECCU::NotFound
  #     puts "No request can be found with the given code"
  #   rescue AkamaiApi::Unauthorized
  #     puts "Invalid login credentials"
  #   end
  class UpdateAttributeRequest < BaseEditRequest
    # @return [String] attribute to update
    attr_reader :attribute

    # Updates an attribute of an ECCU request
    # @param [Fixnum] code request code
    # @param [String] attribute name
    # @param [String] value new value to set
    # @return [true,false] whether the request was successful or not
    def self.execute code, attribute, value
      new(code, attribute).execute(value)
    end

    # @param [Fixnum] code request code
    # @param [String] attribute name
    def initialize code, attribute
      super code
      @attribute = attribute
    end

    # Updates an attribute of an ECCU request
    # @param [String] value new value to set
    # @return [true,false] whether the request was successful or not
    def execute value
      with_soap_error_handling do
        client_call(:"set_#{attribute}", message: request_body(value).to_s)[:success]
      end
    end

    protected

    # Creates the request body filling it with all necessary arguments
    # @return [SoapBody]
    def request_body notes
      super do |block|
        block.string  attribute_for_soap,  notes
      end
    end

    private

    def attribute_for_soap
      attribute.to_s.camelize(:lower).to_sym
    end
  end
end
