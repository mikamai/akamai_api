require 'spec_helper'

describe "Given I want to retrieve a request" do
  subject { AkamaiApi::ECCURequest }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_find/invalid_credentials" } do
    before do
      AkamaiApi.stub config: { auth: ['foo', 'bar'] }
      AkamaiApi::ECCU.stub client: AkamaiApi::ECCU.send(:build_client)
    end

    it "raises Unauthorized" do
      expect { subject.find '1234' }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when request id cannot be found", vcr: { cassette_name: "akamai_api_eccu_find/not_found_request" } do
    it "raises NotFound" do
      expect { subject.find '1234' }.to raise_error AkamaiApi::ECCU::NotFound
    end
  end

  context "when request id is found", vcr: { cassette_name: "akamai_api_eccu_find/successful" } do
    it "returns an ECCURequest" do
      expect(subject.find '1234').to be_a AkamaiApi::ECCURequest
    end
  end

  context "when request id is found but verbose is false", vcr: { cassette_name: "akamai_api_eccu_find/successful_without_content" } do
    it "returns an ECCURequest without file content" do
      expect(subject.find('1234', verbose: false).file).to_not have_key :content
    end
  end
end
