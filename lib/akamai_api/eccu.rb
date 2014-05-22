module AkamaiApi::Eccu
  def self.client
    @client ||= build_client
  end

  private

  def self.build_client
    Savon.client client_args
  end

  def self.client_args
    {
      :wsdl       => File.expand_path('../../../wsdls/eccu.wsdl', __FILE__),
      :basic_auth => AkamaiApi.config[:auth],
      :log        => AkamaiApi.config[:log]
    }
  end
end
