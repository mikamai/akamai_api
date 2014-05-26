require "akamai_api/eccu/base_edit_request"

module AkamaiApi::Eccu
  class UpdateAttributeRequest < BaseEditRequest
    attr_reader :attribute

    def initialize code, attribute
      super code
      @attribute = attribute
    end

    def attribute_for_soap
      attribute.to_s.camelize(:lower).to_sym
    end

    def execute value
      with_soap_error_handling do
        client_call(:"set_#{attribute}", message: request_body(value).to_s)[:success]
      end
    end

    def request_body notes
      super do |block|
        block.string  attribute_for_soap,  notes
      end
    end
  end
end
