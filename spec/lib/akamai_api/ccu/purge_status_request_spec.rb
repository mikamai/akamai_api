require 'spec_helper'

describe AkamaiApi::Ccu::PurgeStatusRequest do
  it "includes httparty" do
    expect(subject.class.included_modules).to include HTTParty
  end

  it "sets a base_uri" do
    expect(subject.class.base_uri).to eq 'https://api.ccu.akamai.com'
  end

  describe "#execute" do
    let(:fake_response) { double code: 200, parsed_response: {} }

    it "executes a GET request on the given progress_uri" do
      expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive :get do |uri, args|
        expect(uri).to eq '/ccu/v2/purges/foo'
        fake_response
      end
      subject.execute '/ccu/v2/purges/foo'
    end

    it "sets the auth in the request" do
      AkamaiApi::Ccu.stub auth: 'foo'
      expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive :get do |uri, args|
        expect(args).to eq basic_auth: 'foo'
        fake_response
      end
      subject.execute '/ccu/v2/purges/foo'
    end

    it "raises an exception when the response code is 401" do
      fake_response.stub code: 401
      expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive(:get).and_return fake_response
      expect { subject.execute '/ccu/v2/purges/foo' }.to raise_error AkamaiApi::Ccu::Unauthorized
    end

    it "returns a response built with the received json" do
      fake_response.stub parsed_response: {a: 'b'}
      expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive(:get).and_return fake_response
      expect(subject.execute '/ccu/v2/purges/foo' ).to be_a AkamaiApi::Ccu::PurgeStatusResponse
    end

    context "when the given progressUri is the purgeId" do
      it "the progressUri prefix is appended" do
        expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive :get do |uri, args|
          expect(uri).to eq '/ccu/v2/purges/foo'
          fake_response
        end
        subject.execute 'foo'
      end
    end

    context "when the given progressUri isn't prefixed by a slash" do
      it "a slash is prefixed" do
        expect(AkamaiApi::Ccu::PurgeStatusRequest).to receive :get do |uri, args|
          expect(uri).to eq '/ccu/v2/purges/foo'
          fake_response
        end
        subject.execute 'ccu/v2/purges/foo'
      end
    end
  end
end
