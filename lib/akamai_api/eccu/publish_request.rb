require 'akamai_api/eccu/invalid_domain'
require 'akamai_api/eccu/soap_body'
require "akamai_api/eccu/base_request"

module AkamaiApi::ECCU
  # {PublishRequest} is responsible of publishing a new ECCU request.
  #
  # @example
  #   content = File.read './publish.xml'
  #   begin
  #     req = AkamaiApi::ECCU::PublishRequest.new 'http://foo.bar/t.txt'
  #     code = req.execute content, file_name: 'publish.xml', emails: 'author@mikamai.com'
  #     puts "Request enqueued with code #{code}"
  #   rescue AkamaiApi::Unauthorized
  #     puts "Invalid login credentials"
  #   end
  class PublishRequest < BaseRequest
    # @return [String] Digital property name
    attr_reader :property_name
    # @return [String] Digital property type
    attr_reader :property_type
    # @return [true,false] Digital property match type (true if exact)
    attr_reader :property_exact_match

    # @param [String] property_name Digital property name
    # @param [Hash<Symbol, String>] args Additional arguments
    # @option args [String] :type ('hostheader') Digital property type
    # @option args [true,false] :exact_match (true) Digital property match type
    def initialize property_name, args = {}
      @property_name = property_name
      @property_type = args.fetch(:type, 'hostheader')
      @property_exact_match = args.fetch(:exact_match, true) == true
    end

    # Publishes a new ECCU request
    # @param [String] content content of the ECCU request
    # @param [Hash<Symbol, String>] args Additional arguments
    # @option args [String] :file_name ('') file name to set in the request
    # @option args [String] :notes ('ECCU Request using AkamaiApi <VERSION>') notes of the ECCU request
    # @option args [String] :version ('') request version number
    # @option args [String,Array<String>] :emails emails to notify when the request has been completed
    def execute content, args = {}
      with_soap_error_handling do
        response = client_call :upload, message_tag: 'upload', message: request_body(content, args).to_s
        response[:file_id].to_i
      end
    end

    protected

    # Creates the request body filling it with all necessary arguments
    # @return [SoapBody]
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
      e = AkamaiApi::ECCU::InvalidDomain if e.to_hash[:fault][:faultstring].include? 'You are not authorized to specify this digital property'
      raise e
    end
  end
end
