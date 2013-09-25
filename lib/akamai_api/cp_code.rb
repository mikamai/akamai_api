module AkamaiApi
  class CpCode
    attr_accessor :code, :description, :service

    def initialize attributes
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    def self.all
      response = client.call(:get_cp_codes).body[:multi_ref]
      Array.wrap(response).map do |hash|
        new({
          :code        => hash[:cpcode],
          :description => hash[:description],
          :service     => hash[:service],
        })
      end
    end

    private

    def self.client
      savon_args = {
        :wsdl       => File.expand_path('../../../wsdls/cpcode.wsdl', __FILE__),
        :basic_auth => AkamaiApi.config[:auth],
        :log        => AkamaiApi.config[:log]
      }
      Savon.client savon_args
    end
  end
end