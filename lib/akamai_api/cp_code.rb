module AkamaiApi
  class CpCode
    extend Savon::Model

    document 'https://control.akamai.com/nmrws/services/SiteAcceleratorReportService?wsdl'

    attr_accessor :code, :description, :service

    def initialize attributes
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    def self.all
      result = []
      basic_auth *AkamaiApi.config[:auth]
      client.request('getCPCodes').body[:multi_ref].map do |hash|
        result << new({
          :code        => hash[:cpcode],
          :description => hash[:description],
          :service     => hash[:service],
        })
      end
      result
    end
  end
end