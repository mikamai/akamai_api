require 'spec_helper'

describe AkamaiApi::Ccu::PurgeStatusResponse do
  subject do
    AkamaiApi::Ccu::PurgeStatusResponse.new({
                                              'originalEstimatedSeconds' => 480,
                                              'progressUri'              => '/ccu/v2/purges/12345678-1234-5678-1234-123456789012',
                                              'originalQueueLength'      => 6,
                                              'purgeId'                  => '12345678-1234-5678-1234-123456789012',
                                              'supportId'                => '12345678901234567890-123456789',
                                              'httpStatus'               => 200,
                                              'completionTime'           => '2014-02-19T22:16:20Z',
                                              'submittedBy'              => 'test1',
                                              'purgeStatus'              => 'In-Progress',
                                              'submissionTime'           => '2014-02-19T21:16:20Z',
                                              'pingAfterSeconds'         => 60
                                            })
  end

  it '#estimated_time returns estimatedSeconds attribute' do
    expect(subject.estimated_time).to eq 480
  end

  it '#progress_uri returns progressUri attribute' do
    expect(subject.progress_uri).to eq '/ccu/v2/purges/12345678-1234-5678-1234-123456789012'
  end

  it '#queue_length returns originalQueueLength attribute' do
    expect(subject.queue_length).to eq 6
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

  describe '#completed_at' do
    it 'returns a Time object' do
      expect(subject.completed_at).to be_a Time
    end

    it 'returns completionTime attribute' do
      expect(subject.completed_at.iso8601).to eq '2014-02-19T22:16:20Z'
    end

    it 'can return nil' do
      subject.raw_body['completionTime'] = nil
      expect(subject.completed_at).to be_nil
    end
  end

  it '#submitted_by returns submittedBy attribute' do
    expect(subject.submitted_by).to eq 'test1'
  end

  it '#status returns purgeStatus attribute' do
    expect(subject.status).to eq 'In-Progress'
  end

  it '#message returns detail attribute' do
    subject.raw_body['detail'] = 'asd'
    expect(subject.message).to eq 'asd'
  end

  describe '#submitted_at' do
    it 'returns a Time object' do
      expect(subject.submitted_at).to be_a Time
    end

    it 'can return nil' do
      subject.raw_body['submissionTime'] = nil
      expect(subject.submitted_at).to be_nil
    end

    it 'returns submissionTime attribute' do
      expect(subject.submitted_at.iso8601).to eq '2014-02-19T21:16:20Z'
    end
  end

  it '#time_to_wait returns pingAfterSeconds attribute' do
    expect(subject.time_to_wait).to eq 60
  end
end
