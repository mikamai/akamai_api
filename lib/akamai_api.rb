require 'savon'

%w(version cp_code soap_body ccu_response ccu eccu_request).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  def self.config; @config ||= { :auth => ['', ''], :log => false }; end
end
