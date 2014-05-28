require 'spec_helper'

describe AkamaiApi::CCU::Status::Response do
  let(:raw) do
    {
      'httpStatus' => 201,
      'queueLength' => 1,
      'detail' => 'asd',
      'supportId' => '21'
    }
  end
  subject { AkamaiApi::CCU::Status::Response.new raw }

  it '#code returns the httpStatus property' do
    expect(subject.code).to eq 201
  end

  it '#queue_length returns the queueLength property' do
    expect(subject.queue_length).to eq 1
  end

  it '#message returns the detail property' do
    expect(subject.message).to eq 'asd'
  end

  it '#support_id returns the supportId property' do
    expect(subject.support_id).to eq '21'
  end
end
