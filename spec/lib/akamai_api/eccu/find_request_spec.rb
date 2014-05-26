require 'spec_helper'

describe AkamaiApi::Eccu::FindRequest do
  subject { AkamaiApi::Eccu::FindRequest.new '1234' }

  describe "#execute" do
    it "calls 'get_info' via savon with a message" do
      fake_response = double body: { get_info_response: { success: true } }
      expect(subject).to receive(:request_body).with(true).and_return double(to_s: 'asd')
      expect(AkamaiApi::Eccu.client).to receive(:call).with(:get_info, message: 'asd').and_return fake_response
      subject.execute true
    end

    it "returns a FindResponse" do
      subject.stub request_body: 'example'
      AkamaiApi::Eccu.client.stub call: double(body: { get_info_response: { eccu_info: {} } })
      expect(subject.execute 'foo').to be_a AkamaiApi::Eccu::FindResponse
    end

    it "raises NotFound if request raises a Savon::SOAPFault with particular message" do
      expect(AkamaiApi::Eccu.client).to receive :call do
        exc = Savon::SOAPFault.new({}, {})
        exc.stub to_hash: { fault: { faultstring: 'asdasd fileId xsxx does not exist' } }
        exc.stub to_s: ''
        raise exc
      end
      expect { subject.execute true }.to raise_error AkamaiApi::Eccu::NotFound
    end

    it "raises unauthorized if request raises a Savon::HTTPError with code 401" do
      expect(AkamaiApi::Eccu.client).to receive :call do
        raise Savon::HTTPError, double(code: 401)
      end
      expect { subject.execute true }.to raise_error AkamaiApi::Unauthorized
    end

    it "raises Savon:HTTPError if request raises this exception and its code differs from 401" do
      expect(AkamaiApi::Eccu.client).to receive :call do
        raise Savon::HTTPError, double(code: 402)
      end
      expect { subject.execute true }.to raise_error Savon::HTTPError
    end
  end

  describe "#request_body" do
    it "returns a SoapBody object" do
      expect(subject.request_body false).to be_a AkamaiApi::Eccu::SoapBody
    end

    it "sets an integer value named 'fileId' with the given code" do
      expect_any_instance_of(AkamaiApi::Eccu::SoapBody).to receive(:integer).with :fileId, 1234
      subject.request_body false
    end

    it "sets a boolean value named 'retrieveContents' with the given value" do
      expect_any_instance_of(AkamaiApi::Eccu::SoapBody).to receive(:boolean).with :retrieveContents, false
      subject.request_body '1'
    end

    it "sets only fileId" do
      expect(subject.request_body(false).to_s).to eq "<fileId xsi:type=\"xsd:int\">1234</fileId><retrieveContents xsi:type=\"xsd:boolean\">false</retrieveContents>"
    end
  end
end
