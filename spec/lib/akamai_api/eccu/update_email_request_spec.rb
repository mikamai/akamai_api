require 'spec_helper'

describe AkamaiApi::Eccu::UpdateEmailRequest do
  subject { AkamaiApi::Eccu::UpdateEmailRequest.new '1234' }

  describe "#execute" do
    it "calls 'set_status_change_email' via savon with a message" do
      fake_response = double body: { set_status_change_email_response: { success: true } }
      expect(subject).to receive(:request_body).with('foo').and_return double(to_s: 'asd')
      expect(AkamaiApi::Eccu.client).to receive(:call).with(:set_status_change_email, message: 'asd').and_return fake_response
      subject.execute 'foo'
    end

    it "returns 'true' if response hash reports to be successful" do
      subject.stub request_body: 'example'
      AkamaiApi::Eccu.client.stub call: double(body: { set_status_change_email_response: { success: true } })
      expect(subject.execute 'foo').to be_true
    end

    it "returns 'false' if response hash reports to be unsuccessful" do
      subject.stub request_body: 'example'
      AkamaiApi::Eccu.client.stub call: double(body: { set_status_change_email_response: { success: false } })
      expect(subject.execute 'foo').to be_false
    end

    it "raises unauthorized if request raises a Savon::HTTPError with code 401" do
      expect(AkamaiApi::Eccu.client).to receive :call do
        raise Savon::HTTPError, double(code: 401)
      end
      expect { subject.execute 'foo' }.to raise_error AkamaiApi::Unauthorized
    end

    it "raises Savon:HTTPError if request raises this exception and its code differs from 401" do
      expect(AkamaiApi::Eccu.client).to receive :call do
        raise Savon::HTTPError, double(code: 402)
      end
      expect { subject.execute 'foo' }.to raise_error Savon::HTTPError
    end
  end

  describe "#request_body" do
    it "returns a SoapBody object" do
      expect(subject.request_body 'foo').to be_a AkamaiApi::Eccu::SoapBody
    end

    it "sets an integer value named 'fileId' with the given code" do
      expect_any_instance_of(AkamaiApi::Eccu::SoapBody).to receive(:integer).with :fileId, 1234
      subject.request_body 'foo'
    end

    it "sets a string value named 'statusChangeEmails' with the given email" do
      expect_any_instance_of(AkamaiApi::Eccu::SoapBody).to receive(:string).with :statusChangeEmail, 'foo'
      subject.request_body 'foo'
    end

    it "sets only fileId and email" do
      expect(subject.request_body('foo').to_s).to eq "<fileId xsi:type=\"xsd:int\">1234</fileId><statusChangeEmail xsi:type=\"xsd:string\">foo</statusChangeEmail>"
    end
  end
end
