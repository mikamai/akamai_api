require 'spec_helper'

describe AkamaiApi::Ccu::Response do
  subject { AkamaiApi::Ccu::Response.new 'supportId' => 'foo', 'httpStatus' => 201 }

  it '#support_id returns the supportId attribute' do
    expect(subject.support_id).to eq 'foo'
  end

  %w(code http_status).each do |reader|
    it "##{reader} returns the httpStatus attribute" do
      expect(subject.send reader).to eq 201
    end
  end

  describe "#successful?" do
    it "returns true if the response code is 200" do
      subject.stub code: 200
      expect(subject).to be_successful
    end

    it "returns true if the response code is 201" do
      subject.stub code: 201
      expect(subject).to be_successful
    end

    it "returns false when the response code differs from 200 and 201" do
      subject.stub code: 202
      expect(subject).to_not be_successful
    end
  end
end
