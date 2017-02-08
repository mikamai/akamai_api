require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash"

%w(version ccu eccu eccu_request eccu_parser).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  def self.config
    @config ||= {
      :auth => {},
      :openapi => {},
      :log => false
    }
  end

  def self.auth_empty?
    config[:openapi].select { |v| v.blank? }.any?
  end

  def self.auth
    config[:openapi].symbolize_keys
  end
end
