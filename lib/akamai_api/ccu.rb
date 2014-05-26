require 'httparty'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'akamai_api/ccu/purge'
require 'akamai_api/ccu/status'
require 'akamai_api/ccu/purge_status'

module AkamaiApi
  module Ccu
    extend self

    [:invalidate, :remove].each do |action|
      define_method action do |*params|
        raise ArgumentError, "wrong number of arguments (#{params.length} for 2..3)" if params.length < 2
        type, items, opts = params
        purge action, type, items, (opts || {})
      end
      [:arl, :cpcode].each do |type|
        method_name = "#{action}_#{type}".to_sym
        define_method method_name do |*params|
          raise ArgumentError, "wrong number of arguments (#{params.length} for 1..2)" if params.length < 1
          items, opts = params
          purge action, type, items, (opts || {})
        end
      end
    end

    def purge action, type, items, args = {}
      request = Purge::Request.new action, type, domain: args[:domain]
      request.execute items
    end

    def status progress_uri = nil
      if progress_uri.present?
        PurgeStatus::Request.new.execute progress_uri
      else
        Status::Request.new.execute
      end
    end
  end
end
