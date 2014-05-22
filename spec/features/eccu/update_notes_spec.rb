require 'spec_helper'

describe "Given I want to update the notes of a request" do
  subject { AkamaiApi::EccuRequest.new code: '1234' }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_update_notes/invalid_credentials" } do
    before do
      AkamaiApi.stub config: { auth: ['foo', 'bar'] }
      AkamaiApi::Eccu.stub client: AkamaiApi::Eccu.send(:build_client)
    end

    it "raises Unauthorized" do
      expect { subject.update_notes! 'request updated using AkamaiApi' }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when request id cannot be found", vcr: { cassette_name: "akamai_api_eccu_update_notes/not_found_request" } do
    it "raises NotFound" do
      expect { subject.update_notes! 'request updated using AkamaiApi' }.to raise_error AkamaiApi::Eccu::NotFound
    end
  end

  context "when request id is found", vcr: { cassette_name: "akamai_api_eccu_update_notes/successful" } do
    it "returns true" do
      expect(subject.update_notes! 'request updated using AkamaiApi').to be_true
    end
  end
end
