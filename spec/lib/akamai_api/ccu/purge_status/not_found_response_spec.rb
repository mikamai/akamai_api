require 'spec_helper'

describe AkamaiApi::Ccu::PurgeStatus::NotFoundResponse do
  let(:raw) do
    {
      'progressUri'              => '/ccu/v2/purges/12345678-1234-5678-1234-123456789012',
      'purgeId'                  => '12345678-1234-5678-1234-123456789012',
      'supportId'                => '12345678901234567890-123456789',
      'httpStatus'               => 200,
      'purgeStatus'              => 'Unknown',
      'pingAfterSeconds'         => 60,
      'detail'                   => 'foobarbaz'
    }
  end
  subject { AkamaiApi::Ccu::PurgeStatus::NotFoundResponse.new raw }

  it '#progress_uri returns progressUri attribute' do
    expect(subject.progress_uri).to eq '/ccu/v2/purges/12345678-1234-5678-1234-123456789012'
  end

  it '#purge_id returns purgeId attribute' do
    expect(subject.purge_id).to eq '12345678-1234-5678-1234-123456789012'
  end

  it '#support_id returns supportId attribute' do
    expect(subject.support_id).to eq '12345678901234567890-123456789'
  end

  it '#code returns httpStatus attribute' do
    expect(subject.code).to eq 200
  end

  it '#status returns purgeStatus attribute' do
    expect(subject.status).to eq 'Unknown'
  end

  it '#message returns detail attribute' do
    subject.raw_body['detail'] = 'asd'
    expect(subject.message).to eq 'asd'
  end
end
