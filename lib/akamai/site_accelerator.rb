module Akamai
  class SiteAccelerator
    include Akamai::WebService

    use_manifest 'site_accelerator_report.wsdl'

    service_call :cp_codes do
      resp = client.request('getCPCodes').to_hash[:multi_ref]
      resp.map do |ro|
        {
          :code => ro[:cpcode],
          :description => ro[:description],
          :service => ro[:service]
        }
      end
    end
  end
end
