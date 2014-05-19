require 'savon'

%w(version soap_body ccu eccu_request).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  def self.config; @config ||= { :auth => ['', ''], :log => false }; end
end
