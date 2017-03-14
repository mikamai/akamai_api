require 'active_support'
require 'active_support/core_ext/array'

require "akamai_api/unauthorized"
require "akamai_api/ccu/unrecognized_option"
require "akamai_api/ccu/purge/response"

require "akamai/edgegrid"
require "net/http"
require "uri"
require "json"

module AkamaiApi::CCU::Purge
  # {AkamaiApi::CCU::Purge} encapsulates the behavior needed to purge a resource from Akamai via CCU.
  #
  # @example Remove a single ARL
  #     AkamaiApi::CCU::Purge::Request.new.execute('http://foo.bar/t.txt')
  # @example Invalidate multiple CPCodes
  #     AkamaiApi::CCU::Purge::Request.new(:invalidate, :cpcode).execute(12345, 12346)
  class Request
    @@headers = { "Content-Type" => "application/json" }

    attr_reader :type, :action, :domain

    # @param [String] action type of clean action. See {#action} for allowed values
    # @param [String] type resource type. See {#type} for allowed values
    # @param [Hash<Symbol, String>] args   optional arguments
    # @option args [String] :domain (:production) Domain type. See {#domain} for allowed values
    def initialize action = :remove, type=:arl, args = {}
      self.action = action
      self.type   = type
      self.domain = args[:domain] || :production
    end

    # @!attribute [rw] action
    #   Clean action type.
    #   @return [:invalidate] when you want to simply mark resources as invalid
    #   @return [:remove] when you want to force resources removal
    #   @raise [AkamaiApi::CCU::UnrecognizedOption] if an invalid value is provided
    def action= value
      raise_unrecognized_action(value) unless valid_action?(value)
      @action = value
    end

    # @!attribute [rw] type
    #   Resource type.
    #   @return [:cpcode] when request targets entire CPCode(s)
    #   @return [:arl] when request targets single ARL(s)
    #   @raise [AkamaiApi::CCU::UnrecognizedOption] if an invalid value is provided
    def type= value
      raise_unrecognized_type(value) unless valid_type?(value)
      @type = value
    end

    # @!attribute [rw] domain
    #   Domain type to target.
    #   @return [:production] production environment
    #   @return [:staging] staging environment
    #   @raise [AkamaiApi::CCU::UnrecognizedOption] if an invalid value is provided
    def domain= value
      raise_unrecognized_domain(value) unless valid_domain?(value)
      @domain = value
    end

    # Clean the requested resources.
    # @param [Array<String>] items One or more resources to clean
    # @return [Response] an object representing the received response
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @example Clean a single resource
    #   request.execute 'http://foo.bar/t.txt'
    # @example Clean multiple resources
    #   request.execute '12345', '12346'
    def execute *items
      akamai = Akamai::Edgegrid::HTTP.new(address=baseuri.host, port=baseuri.port)
      akamai.setup_edgegrid(creds)
      http = Net::HTTP.new(address=baseuri.host, port=baseuri.port)
      http.use_ssl = true

      items = Array.wrap(items.first) if items.length == 1
      req = Net::HTTP::Post.new(resource, initheader = @@headers).tap do |pq|
        if for_ccu_v2?
          pq.body = request_body items
        else
          pq.body = {"objects" => items}.to_json
        end
      end

      timestamp = Akamai::Edgegrid::HTTP.eg_timestamp()
      nonce = Akamai::Edgegrid::HTTP.new_nonce()
      req['Authorization'] = akamai.make_auth_header(req, timestamp, nonce)

      parse_response http.request(req)
    end

    # Request body to send to the API.
    # @param [Array<String>] items resources to clean
    # @return [String] request body in JSON format
    def request_body items
      { type: type, action: action, domain: domain, objects: items }.to_json
    end

    private
    def creds
      AkamaiApi.auth.tap do |auth|
        auth.delete(:base_url)
        auth[:max_body] = 128*1024
      end
    end

    def for_ccu_v2?
      @type == :cpcode || (@type == :arl && @action == :remove)
    end

    def resource
      if for_ccu_v2?
        URI.join(baseuri.to_s, "/ccu/v2/queues/default").to_s
      else
        URI.join(baseuri.to_s, "/ccu/v3/#{action}/url/#{domain}").to_s
      end
    end

    def baseuri
      URI(AkamaiApi.auth[:base_url])
    end

    def parse_response response
      parsed_response = JSON.load(response.body)

      raise ::AkamaiApi::Unauthorized if ["400", 401].include?(response.code)
      raise AkamaiApi::CCU::Error.new parsed_response unless successful_response? parsed_response
      Response.new parsed_response
    end

    def raise_unrecognized_action bad_action
      raise ::AkamaiApi::CCU::UnrecognizedOption, "Unknown action '#{bad_action}' (allowed values: invalidate, remove)"
    end

    def raise_unrecognized_type bad_type
      raise ::AkamaiApi::CCU::UnrecognizedOption, "Unknown type '#{bad_type}' (allowed values: arl, cpcode)"
    end

    def raise_unrecognized_domain bad_domain
      raise ::AkamaiApi::CCU::UnrecognizedOption, "Unknown domain '#{bad_domain}' (allowed_values: production, staging)"
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

    def successful_response? response
      (200...300).include? response['httpStatus']
    end
  end
end
