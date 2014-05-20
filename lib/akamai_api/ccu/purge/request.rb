module AkamaiApi::Ccu::Purge
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com/ccu/v2/queues/default'
    headers 'Content-Type' => 'application/json'

    attr_reader :type, :action, :domain

    def initialize action = 'remove', type = 'arl', args = {}
      self.action = action
      self.type   = type
      self.domain = args[:domain] || 'production'
    end

    def action= value
      raise_unrecognized_action(value) unless valid_action?(value)
      @action = value
    end

    def type= value
      raise_unrecognized_type(value) unless valid_type?(value)
      @type = value
    end

    def domain= value
      raise_unrecognized_domain(value) unless valid_domain?(value)
      @domain = value
    end

    def execute *items
      items = Array.wrap(items.first) if items.length == 1
      response = self.class.post('/', basic_auth: auth, body: request_body(items))
      parse_response response
    end

    def auth
      AkamaiApi::Ccu.auth
    end

    def request_body items
      { type: type, action: action, domain: domain, objects: items }.to_json
    end

    private

    def parse_response response
      raise ::AkamaiApi::Ccu::Unauthorized if response.code == 401
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
