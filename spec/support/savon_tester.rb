module SavonTester
  def self.included base
    base.class_eval do
      let(:client) do
        Savon::Client.new do
          wsdl.endpoint = "http://example.com"
          wsdl.namespace = "http://users.example.com"
        end
      end
    end
  end

  def stub_savon_model model
    model.stub :client => client, :basic_auth => nil
  end
end