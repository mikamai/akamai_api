require 'spec_helper'

describe "Given I want to destroy a request" do
  subject { AkamaiApi::ECCURequest.new code: '1234' }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_destroy/invalid_credentials" } do
    before do
      allow(AkamaiApi).to receive(:config) { { auth: ['foo', 'bar'] } }
      allow(AkamaiApi::ECCU).to receive(:client) { AkamaiApi::ECCU.send(:build_client) }
    end

    it "raises Unauthorized" do
      expect { subject.destroy }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when request id cannot be found", vcr: { cassette_name: "akamai_api_eccu_destroy/not_found_request" } do
    it "raises NotFound" do
      expect { subject.destroy }.to raise_error AkamaiApi::ECCU::NotFound
    end
  end

  context "when request id is found", vcr: { cassette_name: "akamai_api_eccu_destroy/successful" } do
    it "returns true" do
      expect(subject.destroy).to be_truthy
    end
  end
end
