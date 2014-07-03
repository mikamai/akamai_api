require 'spec_helper'

describe AkamaiApi::CCU::PurgeStatus::Request do
  it "includes httparty" do
    expect(subject.class.included_modules).to include HTTParty
  end

  it "sets a base_uri" do
    expect(subject.class.base_uri).to eq 'https://api.ccu.akamai.com'
  end

  describe "#execute" do
    let(:fake_response) { double code: 200, parsed_response: { 'httpStatus' => 200, 'submissionTime' => 1 } }

    it "executes a GET request on the given progress_uri" do
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive :get do |uri, args|
        expect(uri).to eq '/ccu/v2/purges/foo'
        fake_response
      end
      subject.execute '/ccu/v2/purges/foo'
    end

    it "sets the auth in the request" do
      allow(AkamaiApi).to receive(:auth) { 'foo' }
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive :get do |uri, args|
        expect(args).to eq basic_auth: 'foo'
        fake_response
      end
      subject.execute '/ccu/v2/purges/foo'
    end

    it "raises an exception when the response code is 401" do
      allow(fake_response).to receive(:code) { 401 }
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive(:get).and_return fake_response
      expect { subject.execute '/ccu/v2/purges/foo' }.to raise_error AkamaiApi::Unauthorized
    end

    it "returns a response built with the received json" do
      allow(fake_response).to receive(:parsed_response) { { 'httpStatus' => 201, 'submissionTime' => 1 } }
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive(:get).and_return fake_response
      expect(subject.execute '/ccu/v2/purges/foo' ).to be_a AkamaiApi::CCU::PurgeStatus::Response
    end

    it "raises an error if json code in response is not valid" do
      allow(fake_response).to receive(:parsed_response) { { 'httpStatus' => 400, 'submissionTime' => 1 } }
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive(:get).and_return fake_response
      expect { subject.execute '/ccu/v2/purges/foo' }.to raise_error AkamaiApi::CCU::Error
    end

    it "raises an error when json code in response has no submissionTime" do
      fake_response = double code: 201, parsed_response: { 'httpStatus' => 201 }
      expect(AkamaiApi::CCU::PurgeStatus::Request).to receive(:get).and_return fake_response
      expect { subject.execute '/ccu/v2/purges/foo' }.to raise_error AkamaiApi::CCU::PurgeStatus::NotFound
    end

    context "when the given progressUri is the purgeId" do
      it "the progressUri prefix is appended" do
        expect(AkamaiApi::CCU::PurgeStatus::Request).to receive :get do |uri, args|
          expect(uri).to eq '/ccu/v2/purges/foo'
          fake_response
        end
        subject.execute 'foo'
      end
    end

    context "when the given progressUri isn't prefixed by a slash" do
      it "a slash is prefixed" do
        expect(AkamaiApi::CCU::PurgeStatus::Request).to receive :get do |uri, args|
          expect(uri).to eq '/ccu/v2/purges/foo'
          fake_response
        end
        subject.execute 'ccu/v2/purges/foo'
      end
    end
  end
end
