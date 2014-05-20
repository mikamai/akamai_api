require 'spec_helper'

describe AkamaiApi::Ccu::PurgeRequest do
  it "includes httparty" do
    expect(subject.class.included_modules).to include HTTParty
  end

  it "sets a base_uri" do
    expect(subject.class.base_uri).to eq 'https://api.ccu.akamai.com/ccu/v2/queues/default'
  end

  it "sets a content type header" do
    expect(subject.class.headers).to eq 'Content-Type' => 'application/json'
  end

  describe "#action" do
    it "is 'remove' by default" do
      expect(subject.action).to eq 'remove'
    end

    it "can be changed" do
      expect { subject.action = 'invalidate' }.to change(subject, :action).to 'invalidate'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.action = 'foobar' }.to raise_error AkamaiApi::Ccu::UnrecognizedOption
    end
  end

  describe "#type" do
    it "is 'arl' by default" do
      expect(subject.type).to eq 'arl'
    end

    it "can be changed" do
      expect { subject.type = 'cpcode' }.to change(subject, :type).to eq 'cpcode'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.type = 'foobar' }.to raise_error AkamaiApi::Ccu::UnrecognizedOption
    end
  end

  describe "#domain" do
    it "is 'production' by default" do
      expect(subject.domain).to eq 'production'
    end

    it "can be changed" do
      expect { subject.domain = 'staging' }.to change(subject, :domain).to eq 'staging'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.domain = 'foobar' }.to raise_error AkamaiApi::Ccu::UnrecognizedOption
    end
  end

  describe "#execute" do
    let(:fake_response) { double code: 201, parsed_response: {} }
    let(:sample_arl) { 'http://www.foo.bar/t.txt' }

    it "executes a post on the base url" do
      expect(subject.class).to receive :post do |path, args|
        expect(path).to eq '/'
        fake_response
      end
      subject.execute sample_arl
    end

    it "sets the auth in the post" do
      subject.stub auth: 'foo'
      expect(subject.class).to receive :post do |path, args|
        expect(args[:basic_auth]).to eq 'foo'
        fake_response
      end
      subject.execute sample_arl
    end

    it "accepts a single element" do
      expect(subject).to receive(:request_body).with([sample_arl])
      subject.class.stub post: fake_response
      subject.execute sample_arl
    end

    it "accepts a collection with a single element" do
      expect(subject).to receive(:request_body).with([sample_arl])
      subject.class.stub post: fake_response
      subject.execute sample_arl
    end

    it "accepts a collection" do
      expect(subject).to receive(:request_body).with(['a', 'b'])
      subject.class.stub post: fake_response
      subject.execute ['a', 'b']
    end

    it "works with splatting" do
      expect(subject).to receive(:request_body).with(['a', 'b'])
      subject.class.stub post: fake_response
      subject.execute 'a', 'b'
    end

    it "sets the request body" do
      expect(subject).to receive(:request_body).with([sample_arl]).and_return 'foo'
      expect(subject.class).to receive :post do |path, args|
        expect(args[:body]).to eq 'foo'
        fake_response
      end
      subject.execute sample_arl
    end

    it "raises an exception when the response code is 401" do
      fake_response = double code: 401
      subject.class.stub post: fake_response
      expect { subject.execute sample_arl }.to raise_error AkamaiApi::Ccu::Unauthorized
    end

    it "returns a response built with the resulted json" do
      fake_response = double code: 201, parsed_response: { a: 'b' }
      subject.class.stub post: fake_response
      expect(subject.execute(sample_arl).raw_body).to eq a: 'b'
    end
  end
end
