require 'httparty'
require 'active_support/core_ext'
require 'akamai_api/ccu/purge_response'
require 'akamai_api/ccu/purge_request'
require 'akamai_api/ccu/status_response'
require 'akamai_api/ccu/status_request'

module AkamaiApi
  module Ccu
    extend self

    class UnrecognizedOption < StandardError; end
    class Unauthorized < StandardError; end

    [:invalidate, :remove].each do |action|
      send :define_method, action do |*params|
        raise ArgumentError, "wrong number of arguments (#{params.length} for 2..3)" if params.length < 2
        type, items, opts = params
        purge action, type, items, (opts || {})
      end
      [:arl, :cpcode].each do |type|
        method_name = "#{action}_#{type}".to_sym
        send :define_method, method_name do |*params|
          raise ArgumentError, "wrong number of arguments (#{params.length} for 1..2)" if params.length < 1
          items, opts = params
          purge action, type, items, (opts || {})
        end
      end
    end

    def purge action, type, items, args = {}
      request = PurgeRequest.new action, type, domain: args[:domain]
      request.execute items
    end

    def status
      StatusRequest.new.execute
    end

    def self.auth
      { username: AkamaiApi.config[:auth].first, password: AkamaiApi.config[:auth].last }
    end
  end
end
