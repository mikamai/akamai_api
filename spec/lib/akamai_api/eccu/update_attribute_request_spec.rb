require 'spec_helper'

describe AkamaiApi::ECCU::UpdateAttributeRequest do
  subject { AkamaiApi::ECCU::UpdateAttributeRequest.new '1234', :status_change_email }

  describe '#attribute_for_soap' do
    it 'returns a camelized symbol with first letter in downcase' do
      expect(subject.send :attribute_for_soap).to eq :statusChangeEmail
    end
  end

  describe "#execute" do
    let(:fake_client) { double call: nil }

    before do
      allow(AkamaiApi::ECCU).to receive(:client) { fake_client }
    end

    it "calls the appropriate soap method via savon with a message" do
      fake_response = double body: { set_status_change_email_response: { success: true } }
      expect(subject).to receive(:request_body).with('foo').and_return double(to_s: 'asd')
      expect(fake_client).to receive(:call).with(:set_status_change_email, message: 'asd').and_return fake_response
      subject.execute 'foo'
    end

    it "returns 'true' if response hash reports to be successful" do
      allow(subject).to receive(:request_body) { 'example' }
      allow(fake_client).to receive(:call) { double(body: { set_status_change_email_response: { success: true } }) }
      expect(subject.execute 'foo').to be_truthy
    end

    it "returns 'false' if response hash reports to be unsuccessful" do
      allow(subject).to receive(:request_body) { 'example' }
      allow(fake_client).to receive(:call) { double(body: { set_status_change_email_response: { success: false } }) }
      expect(subject.execute 'foo').to be_falsy
    end

    it "raises NotFound if request raises a Savon::SOAPFault with particular message" do
      expect(fake_client).to receive :call do
        exc = Savon::SOAPFault.new({}, {})
        allow(exc).to receive(:to_hash) { { fault: { faultstring: 'asdasd fileId xsxx does not exist' } } }
        allow(exc).to receive(:to_s) { '' }
        raise exc
      end
      expect { subject.execute 'foo' }.to raise_error AkamaiApi::ECCU::NotFound
    end

    it "raises unauthorized if request raises a Savon::HTTPError with code 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 401)
      end
      expect { subject.execute 'foo' }.to raise_error AkamaiApi::Unauthorized
    end

    it "raises Savon:HTTPError if request raises this exception and its code differs from 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 402)
      end
      expect { subject.execute 'foo' }.to raise_error Savon::HTTPError
    end
  end

  describe "#request_body" do
    def subject_request_body *args
      subject.send :request_body, *args
    end

    it "returns a SoapBody object" do
      expect(subject_request_body 'foo').to be_a AkamaiApi::ECCU::SoapBody
    end

    it "sets an integer value named 'fileId' with the given code" do
      expect_any_instance_of(AkamaiApi::ECCU::SoapBody).to receive(:integer).with :fileId, 1234
      subject_request_body 'foo'
    end

    it "sets a string value named 'statusChangeEmails' with the given email" do
      expect_any_instance_of(AkamaiApi::ECCU::SoapBody).to receive(:string).with :statusChangeEmail, 'foo'
      subject_request_body 'foo'
    end

    it "sets only fileId and email" do
      expect(subject_request_body('foo').to_s).to eq "<fileId xsi:type=\"xsd:int\">1234</fileId><statusChangeEmail xsi:type=\"xsd:string\">foo</statusChangeEmail>"
    end
  end
end
