require "httparty"
require 'active_support'
require 'active_support/core_ext/array'
require "akamai_api/unauthorized"
require "akamai_api/ccu/unrecognized_option"
require "akamai_api/ccu/purge/response"

module AkamaiApi::Ccu::Purge
  # This class encapsulates the behavior needed to purge a resource from Akamai via CCU.
  # When you build an instance of this class you specify what type of operation you want to do.
  # Then each time you call {#execute} a request is made to Akamai to clean the specified resources
  #
  # @example Remove a single ARL
  #     AkamaiApi::Ccu::Purge::Request.new.execute('http://foo.bar/t.txt')
  # @example Invalidate multiple CPCodes
  #     AkamaiApi::Ccu::Purge::Request.new(:invalidate, :cpcode).execute(12345, 12346)
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com/ccu/v2/queues/default'
    headers 'Content-Type' => 'application/json'

    attr_reader :type, :action, :domain

    # @param [String] action type of clean action. See {#action} for allowed values
    # @param [String] type   type of resource to clean. See {#type} for allowed values
    # @param [Hash]   args   optional arguments
    # @option args [String] :domain Domain type to clean. See {#domain} for allowed values
    def initialize action = 'remove', type = 'arl', args = {}
      self.action = action
      self.type   = type
      self.domain = args[:domain] || 'production'
    end

    # @!attribute [rw] action
    #   Type of clean action. Allowed values are:
    #   - :invalidate (to simply mark resources as invalid)
    #   - :remove (to force resource removal)
    #   @return [String,Symbol]
    #   @raise [AkamaiApi::Ccu::UnrecognizedOption] if an invalid value is provided
    def action= value
      raise_unrecognized_action(value) unless valid_action?(value)
      @action = value
    end

    # @!attribute [rw] type
    #   Type of resource to clean. Allowed values are:
    #   - :cpcode (to clean a CPCode)
    #   - :arl    (to clean a regular URL)
    #   @return [String,Symbol]
    #   @raise [AkamaiApi::Ccu::UnrecognizedOption] if an invalid value is provided
    def type= value
      raise_unrecognized_type(value) unless valid_type?(value)
      @type = value
    end

    # @!attribute [rw] domain
    #   Domain type to clean. Allowed values are:
    #   - :production
    #   - :staging
    #   @return [String,Symbol]
    #   @raise [AkamaiApi::Ccu::UnrecognizedOption] if an invalid value is provided
    def domain= value
      raise_unrecognized_domain(value) unless valid_domain?(value)
      @domain = value
    end

    # Clean the requested resources
    # @param [Array] items One or more resources to clean
    # @return [Response] an object representing the received response
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @example Clean a single resource
    #   request.execute 'http://foo.bar/t.txt
    # @example Clean multiple resources
    #   request.execute '12345', '12346'
    def execute *items
      items = Array.wrap(items.first) if items.length == 1
      response = self.class.post('/', basic_auth: AkamaiApi.auth, body: request_body(items))
      parse_response response
    end

    def request_body items
      { type: type, action: action, domain: domain, objects: items }.to_json
    end

    private

    def parse_response response
      raise ::AkamaiApi::Unauthorized if response.code == 401
      Response.new response.parsed_response
    end

    def raise_unrecognized_action bad_action
      raise ::AkamaiApi::Ccu::UnrecognizedOption, "Unknown action '#{bad_action}' (allowed values: invalidate, remove)"
    end

    def raise_unrecognized_type bad_type
      raise ::AkamaiApi::Ccu::UnrecognizedOption, "Unknown type '#{bad_type}' (allowed values: arl, cpcode)"
    end

    def raise_unrecognized_domain bad_domain
      raise ::AkamaiApi::Ccu::UnrecognizedOption, "Unknown domain '#{bad_domain}' (allowed_values: production, staging)"
    end

    def valid_action? action
      %w(invalidate remove).include? action.to_s
    end

    def valid_type? type
      %w(arl cpcode).include? type.to_s
    end

    def valid_domain? domain
      %w(production staging).include? domain.to_s
    end
  end
end
