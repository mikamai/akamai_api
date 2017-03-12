require 'spec_helper'

describe AkamaiApi::CCU::Purge::Request do
  describe "#action" do
    it "is :remove by default" do
      expect(subject.action).to eq :remove
    end

    it "can be changed" do
      expect { subject.action = 'invalidate' }.to change(subject, :action).to 'invalidate'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.action = 'foobar' }.to raise_error AkamaiApi::CCU::UnrecognizedOption
    end
  end

  describe "#type" do
    it "is :arl by default" do
      expect(subject.type).to eq :arl
    end

    it "can be changed" do
      expect { subject.type = 'cpcode' }.to change(subject, :type).to eq 'cpcode'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.type = 'foobar' }.to raise_error AkamaiApi::CCU::UnrecognizedOption
    end
  end

  describe "#domain" do
    it "is :production by default" do
      expect(subject.domain).to eq :production
    end

    it "can be changed" do
      expect { subject.domain = 'staging' }.to change(subject, :domain).to eq 'staging'
    end

    it "raises an error if an invalid value is set" do
      expect { subject.domain = 'foobar' }.to raise_error AkamaiApi::CCU::UnrecognizedOption
    end
  end

  describe "#execute" do
    let(:fake_response) { double code: 201, parsed_response: { 'httpStatus' => 201, 'submissionTime' => 1 } }
    let(:sample_arl) { 'http://www.foo.bar/t.txt' }

    before(:each) do
      allow_any_instance_of(Akamai::Edgegrid::HTTP).to receive(:request).and_return(double code: 201, body: '{ "httpStatus" : 201}')
    end

    it "executes a post on the base url" do
      expect_any_instance_of(Akamai::Edgegrid::HTTP).to receive(:request).with an_instance_of(Net::HTTP::Post)
      subject.execute sample_arl
    end

    it "sets the auth in the post" do
      expect_any_instance_of(Akamai::Edgegrid::HTTP).to receive(:setup_edgegrid).with({:username => 'USERNAME', :password => 'PASSWORD', :max_body=>131072, :client_token => "client_token", :client_secret => "client_secret", :access_token => "access_token"})
      subject.execute sample_arl
    end

    it "sets headers and base uri" do
      fake_net_http_post = double
      allow(fake_net_http_post).to receive(:body=)
      expect(Net::HTTP::Post).to receive(:new) do |base_uri, initheaders|
        expect(base_uri).to eq "https://some-subdomain.luna.akamaiapis.net/ccu/v3/remove/url/production"
        expect(initheaders)
        fake_net_http_post
      end
      subject.execute sample_arl
    end

    it "accepts a single element" do
      require "json"
      expect_any_instance_of(Net::HTTP::Post).to receive(:body=).with({"objects" => ['http://www.foo.bar/t.txt']}.to_json)
      subject.execute sample_arl
    end

    it "accepts a collection" do
      require "json"
      expect_any_instance_of(Net::HTTP::Post).to receive(:body=).with({"objects" => ["a", "b"]}.to_json)
      subject.execute ["a", "b"]
    end

    it "works with splatting" do
      require "json"
      expect_any_instance_of(Net::HTTP::Post).to receive(:body=).with({"objects" => ["a", "b"]}.to_json)
      subject.execute "a", "b"
    end

    it "raises an exception when the response code is 401" do
      fake_response = double code: 401, body: '{ "httpStatus" : 401}'
      allow_any_instance_of(Akamai::Edgegrid::HTTP).to receive(:request) { fake_response }
      expect { subject.execute sample_arl }.to raise_error AkamaiApi::Unauthorized
    end

    it "returns a response built with the resulted json" do
      fake_response = double code: 201, parsed_response: { 'httpStatus' => 201 }
      allow(subject.class).to receive(:post) { fake_response }
      expect(subject.execute(sample_arl).raw).to eq 'httpStatus' => 201
    end

    it "raises an error when json code in response is not successful" do
      fake_response = double code: 403, body: '{ "httpStatus" : 403 }'
      allow_any_instance_of(Akamai::Edgegrid::HTTP).to receive(:request) { fake_response }
      expect { subject.execute sample_arl }.to raise_error AkamaiApi::CCU::Error
    end
  end
end
