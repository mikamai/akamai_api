require 'spec_helper'

describe "Given I request a purge status" do
  subject { AkamaiApi::Ccu }

  context "when login credentials are ok and progress uri is valid", vcr: { cassette_name: "ccu/purge_status/successful" } do
    let(:progress_uri) { '/ccu/v2/purges/12345678-1234-5678-1234-123456789012' }

    it "responds with a PurgeStatusResponse object" do
      expect(subject.status progress_uri).to be_a AkamaiApi::Ccu::PurgeStatusResponse
    end
  end

  context "when login credentials are invalid", vcr: { cassette_name: "ccu/purge_status/unauthorized" } do
    let(:progress_uri) { '/ccu/v2/purges/12345678-1234-5678-1234-123456789012' }

    before do
      AkamaiApi::Ccu.stub auth: { username: 'foo', password: 'bar' }
    end

    it "raises an error" do
      expect { subject.status progress_uri }.to raise_error AkamaiApi::Ccu::Unauthorized
    end
  end

  context "when the given progress uri is invalid", vcr: { cassette_name: "ccu/purge_status/invalid" } do
    it "returns a correct response" do
      expect(subject.status 'foobarbaz').to be_a AkamaiApi::Ccu::PurgeStatusResponse
    end
  end
end
