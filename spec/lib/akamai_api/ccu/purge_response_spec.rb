require 'spec_helper'

describe AkamaiApi::Ccu::PurgeResponse do
  subject do
    AkamaiApi::Ccu::PurgeResponse.new({
                                        'describedBy' => 'foo',
                                        'title' => 'bar',
                                        'pingAfterSeconds' => 100,
                                        'purgeId' => '120',
                                        'supportId' => '130',
                                        'detail' => 'baz',
                                        'httpStatus' => 201,
                                        'estimatedSeconds' => 90,
                                        'progressUri' => 'http://asd.com'
                                      })
  end

  it '#described_by returns the describedBy attribute' do
    expect(subject.described_by).to eq 'foo'
  end

  it '#title returns the title attribute' do
    expect(subject.title).to eq 'bar'
  end

  it '#time_to_wait returns the pingAfterSeconds attribute' do
    expect(subject.time_to_wait).to eq 100
  end

  it '#purge_id returns the purgeId attribute' do
    expect(subject.purge_id).to eq '120'
  end

  it '#support_id returns the supportId attribute' do
    expect(subject.support_id).to eq '130'
  end

  it '#message returns the detail attribute' do
    expect(subject.message).to eq 'baz'
  end

  it '#code returns the httpStatus attribute' do
    expect(subject.code).to eq 201
  end

  it '#estimated_time returns the estimatedSeconds attribute' do
    expect(subject.estimated_time).to eq 90
  end

  it '#uri returns the progressUri attribute' do
    expect(subject.uri).to eq 'http://asd.com'
  end
end
