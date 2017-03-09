require 'spec_helper'

describe AkamaiApi::CCU::Purge::Response do
  let(:raw) do
    {
      "httpStatus" => 201,
      "detail"     => "Request accepted.",
      "estimatedSeconds" => 420,
      "purgeId" => "95b5a092-043f-4af0-843f-aaf0043faaf0",
      "progressUri" => "/ccu/v2/purges/95b5a092-043f-4af0-843f-aaf0043faaf0",
      "pingAfterSeconds" => 420,
      "supportId" => "17PY1321286429616716-211907680"
    }
  end
  subject { AkamaiApi::CCU::Purge::Response.new raw }

  it '#detail returns the title attribute' do
    expect(subject.detail).to eq 'Request accepted.'
  end

  it '#time_to_wait returns the pingAfterSeconds attribute' do
    expect(subject.time_to_wait).to eq 420
  end

  it '#purge_id returns the purgeId attribute' do
    expect(subject.purge_id).to eq "95b5a092-043f-4af0-843f-aaf0043faaf0"
  end

  it '#support_id returns the supportId attribute' do
    expect(subject.support_id).to eq "17PY1321286429616716-211907680"
  end

  it '#code returns the httpStatus attribute' do
    expect(subject.code).to eq 201
  end

  it '#estimated_time returns the estimatedSeconds attribute' do
    expect(subject.estimated_time).to eq 420
  end

  it '#uri returns the progressUri attribute' do
    expect(subject.uri).to eq "/ccu/v2/purges/95b5a092-043f-4af0-843f-aaf0043faaf0"
  end
end
