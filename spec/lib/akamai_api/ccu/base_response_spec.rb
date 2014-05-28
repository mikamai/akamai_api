require 'spec_helper'

describe AkamaiApi::CCU::BaseResponse do
  subject { AkamaiApi::CCU::BaseResponse.new 'supportId' => 'foo', 'httpStatus' => 201 }

  it '#support_id returns the supportId attribute' do
    expect(subject.support_id).to eq 'foo'
  end

  %w(code http_status).each do |reader|
    it "##{reader} returns the httpStatus attribute" do
      expect(subject.send reader).to eq 201
    end
  end
end
