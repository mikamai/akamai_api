require 'akamai_api/eccu/invalid_domain'

module AkamaiApi::Eccu
  class PublishRequest < BaseRequest
    attr_reader :property_name, :property_type, :property_exact_match

    def initialize property_name, args = {}
      @property_name = property_name
      @property_type = args.fetch(:type, 'hostheader')
      @property_exact_match = args.fetch(:exact_match, true) == true
    end

    def execute content, args = {}
      with_soap_error_handling do
        response = client_call :upload, message_tag: 'upload', message: request_body(content, args).to_s
        response[:file_id].to_i
      end
    end

    def request_body content, args
      SoapBody.new.tap do |body|
        body.string :filename,               args.fetch(:file_name, '')
        body.text   :contents,               content
        body.string :notes,                  args.fetch(:notes, "ECCU Request using AkamaiApi #{AkamaiApi::VERSION}")
        body.string :versionString,          args.fetch(:version, '')
        if args[:emails]
          body.string :statusChangeEmail,    Array.wrap(args[:emails]).join(',')
        end
        body.string      :propertyName,           property_name
        body.string      :propertyType,           property_type
        body.boolean     :propertyNameExactMatch, property_exact_match
      end
    end

    def with_soap_error_handling &block
      super
    rescue Savon::SOAPFault => e
      e = AkamaiApi::Eccu::InvalidDomain if e.to_hash[:fault][:faultstring].include? 'You are not authorized to specify this digital property'
      raise e
    end
  end
end
