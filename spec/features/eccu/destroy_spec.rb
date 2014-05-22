require 'spec_helper'

describe "Given I want to destroy a request" do
  subject { AkamaiApi::EccuRequest.new code: '1234' }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_destroy/invalid_credentials" } do
    before do
      AkamaiApi.stub config: { auth: ['foo', 'bar'] }
      AkamaiApi::Eccu.stub client: AkamaiApi::Eccu.send(:build_client)
    end

    it "raises Unauthorized" do
      expect { subject.destroy }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when request id cannot be found", vcr: { cassette_name: "akamai_api_eccu_destroy/not_found_request" } do
    it "raises NotFound" do
      expect { subject.destroy }.to raise_error AkamaiApi::Eccu::NotFound
    end
  end

  context "when request id is found", vcr: { cassette_name: "akamai_api_eccu_destroy/successful" } do
    it "returns true" do
      expect(subject.destroy).to be_true
    end
  end
end
