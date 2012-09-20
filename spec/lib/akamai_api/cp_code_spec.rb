require 'spec_helper'

module AkamaiApi
  describe CpCode do
    let(:client) do
      Savon::Client.new do
        wsdl.endpoint = "http://example.com"
        wsdl.namespace = "http://users.example.com"
      end
    end

    describe '::all' do
      before do
        savon.expects('getCPCodes').returns(:sample)
        CpCode.stub :client => client, :basic_auth => nil
      end

      it 'should return a collection of models' do
        CpCode.all.each { |o| o.should be_a CpCode }
      end

      it 'should correctly fill each object' do
        model = CpCode.all.first
        model.code.should == '12345'
        model.description.should == 'Foo Site'
        model.service.should == 'Site_Accel::Site_Accel'
      end
    end
  end
end