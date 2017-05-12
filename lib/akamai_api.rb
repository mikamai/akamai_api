require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash"

%w(version ccu eccu eccu_request eccu_parser).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  def self.config
    @config ||= {
      :auth => [
        ENV.fetch('AKAMAI_USERNAME', ''),
        ENV.fetch('AKAMAI_PASSWORD', ''),
      ],
      :openapi => {},
      :log => false
    }
  end

  def self.auth_empty?
    config[:auth].select { |v| v.blank? }.any?
  end

  def self.auth_ok?
    [:username, :password, :base_url, :client_token, :client_secret, :access_token ].all? { |k| auth.key? k }
  end

  def self.auth
    { username: config[:auth].first, password: config[:auth].last }.merge(config[:openapi].symbolize_keys)
  end
end
