require 'spec_helper'

describe "Given I want to update the email of a request" do
  subject { AkamaiApi::ECCURequest.new code: '1234' }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_update_email/invalid_credentials" } do
    before do
      AkamaiApi.stub config: { auth: ['foo', 'bar'] }
      AkamaiApi::ECCU.stub client: AkamaiApi::ECCU.send(:build_client)
    end

    it "raises Unauthorized" do
      expect { subject.update_email! 'guest@mikamai.com' }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when request id cannot be found", vcr: { cassette_name: "akamai_api_eccu_update_email/not_found_request" } do
    it "raises NotFound" do
      expect { subject.update_email! 'guest@mikamai.com' }.to raise_error AkamaiApi::ECCU::NotFound
    end
  end

  context "when request id is found", vcr: { cassette_name: "akamai_api_eccu_update_email/successful" } do
    it "returns true" do
      expect(subject.update_notes! 'guest@mikamai.com').to be_true
    end
  end
end
