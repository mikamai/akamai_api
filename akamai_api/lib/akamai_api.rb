require 'savon'

%w(version cp_code soap_body ccu_response ccu eccu_request).each do |file|
  require File.expand_path "../akamai_api/#{file}", __FILE__
end

module AkamaiApi
  def self.config; @config ||= { :auth => ['', ''] }; end
end