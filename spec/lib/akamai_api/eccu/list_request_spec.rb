require 'spec_helper'

describe AkamaiApi::ECCU::ListRequest do
  subject { AkamaiApi::ECCU::ListRequest.new }

  describe "#execute" do
    let(:fake_client) { double call: nil }

    before do
      AkamaiApi::ECCU.stub client: fake_client
    end

    it "calls 'get_ids' via savon" do
      fake_response = double body: { get_ids_response: { file_ids: { file_ids: [1,2] } } }
      expect(fake_client).to receive(:call).with(:get_ids).and_return fake_response
      subject.execute
    end

    it "returns an array of ids" do
      fake_client.stub call: double(body: { get_ids_response: { file_ids: { file_ids: [1,2] } } })
      expect(subject.execute).to eq [1,2]
    end

    it "wraps in array if only one result is returned" do
      fake_client.stub call: double(body: { get_ids_response: { file_ids: { file_ids: 1 } } })
      expect(subject.execute).to eq [1]
    end

    it "raises unauthorized if request raises a Savon::HTTPError with code 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 401)
      end
      expect { subject.execute }.to raise_error AkamaiApi::Unauthorized
    end

    it "raises Savon:HTTPError if request raises this exception and its code differs from 401" do
      expect(fake_client).to receive :call do
        raise Savon::HTTPError, double(code: 402)
      end
      expect { subject.execute }.to raise_error Savon::HTTPError
    end
  end
end
