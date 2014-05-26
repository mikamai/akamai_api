require 'spec_helper'

describe "Given I want to retrieve all submitted request ids" do
  subject { AkamaiApi::EccuRequest }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_all_ids/invalid_credentials" } do
    before do
      AkamaiApi.stub config: { auth: ['foo', 'bar'] }
      AkamaiApi::Eccu.stub client: AkamaiApi::Eccu.send(:build_client)
    end

    it "raises Unauthorized" do
      expect { subject.all_ids }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when credentials are valid", vcr: { cassette_name: "akamai_api_eccu_all_ids/successful" } do
    it "returns a list of ids" do
      expect(subject.all_ids).to eq ["12341", "12342", "12343", "12344", "12345", "12346", "12347", "12348", "12349", "12350", "12351", "12352", "12353", "12354", "12355", "12356", "12357", "12358", "12359", "12360", "12361", "12362", "12363", "12364", "12365", "12366", "12367", "12368", "12369", "12370", "12371"]
    end
  end
end
