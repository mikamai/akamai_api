require 'savon'

%w(version soap_body ccu eccu_request).each do |file|
  require "akamai_api/#{file}"
end

module AkamaiApi
  class Unauthorized < StandardError; end

  def self.config; @config ||= { :auth => ['', ''], :log => false }; end
end
