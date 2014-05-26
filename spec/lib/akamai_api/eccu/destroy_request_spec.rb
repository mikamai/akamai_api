require 'spec_helper'

describe AkamaiApi::Eccu::DestroyRequest do
  subject { AkamaiApi::Eccu::DestroyRequest.new '1234' }

  describe "#execute" do
    let(:fake_client) { double call: nil }

    before do
      AkamaiApi::Eccu.stub client: fake_client
    end

    it "calls 'delete' via savon with a message" do
      fake_response = double body: { delete_response: { success: true } }
      expect(subject).to receive(:request_body).and_return double(to_s: 'asd')
      expect(fake_client).to receive(:call).with(:delete, message: 'asd').and_return fake_response
      subject.execute
    end

    it "returns 'true' if response hash reports to be successful" do
      subject.stub request_body: 'example'
      fake_client.stub call: double(body: { delete_response: { success: true } })
      expect(subject.execute).to be_true
    end

    it "returns 'false' if response hash reports to be unsuccessful" do
      subject.stub request_body: 'example'
      fake_client.stub call: double(body: { delete_response: { success: false } })
      expect(subject.execute).to be_false
    end

    it "raises NotFound if request raises a Savon::SOAPFault with particular message" do
      expect(fake_client).to receive :call do
        exc = Savon::SOAPFault.new({}, {})
        exc.stub to_hash: { fault: { faultstring: 'asdasd fileId xsxx does not exist' } }
        exc.stub to_s: ''
        raise exc
      end
      expect { subject.execute }.to raise_error AkamaiApi::Eccu::NotFound
    end

    it "raises unauthorized if request raises a Savon::HTTPError with code 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 401)
      end
      expect { subject.execute }.to raise_error AkamaiApi::Unauthorized
    end

    it "raises Savon:HTTPError if request raises this exception and its code differs from 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 402)
      end
      expect { subject.execute }.to raise_error Savon::HTTPError
    end
  end

  describe "#request_body" do
    it "returns a SoapBody object" do
      expect(subject.request_body).to be_a AkamaiApi::Eccu::SoapBody
    end

    it "sets an integer value named 'fileId' with the given code" do
      expect_any_instance_of(AkamaiApi::Eccu::SoapBody).to receive(:integer).with :fileId, 1234
      subject.request_body
    end

    it "sets only fileId" do
      expect(subject.request_body.to_s).to eq "<fileId xsi:type=\"xsd:int\">1234</fileId>"
    end
  end
end
