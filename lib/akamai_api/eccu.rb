module AkamaiApi::Eccu
  def self.client
    @client ||= Savon.client client_args
  end

  private

  def self.client_args
    {
      :wsdl       => File.expand_path('../../../wsdls/eccu.wsdl', __FILE__),
      :basic_auth => AkamaiApi.config[:auth],
      :log        => AkamaiApi.config[:log]
    }
  end
end
