require "active_support/core_ext/object/blank"

%w(version ccu eccu eccu_request eccu_parser).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  def self.config
    @config ||= {
      :auth => [
        ENV.fetch('AKAMAI_USERNAME', ''),
        ENV.fetch('AKAMAI_PASSWORD', '')
      ],
      :log => false
    }
  end

  def self.auth_empty?
    config[:auth].select { |v| v.blank? }.any?
  end

  def self.auth
    { username: config[:auth].first, password: config[:auth].last }
  end
end
