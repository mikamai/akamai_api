require 'spec_helper'

describe AkamaiApi::CCU::Status::Request do
  it 'executes a get upon base url passing the basic auth' do
    fake_response = double code: 200, parsed_response: {}
    allow(AkamaiApi).to receive(:auth) { 'foo' }
    expect(AkamaiApi::CCU::Status::Request).to receive(:get).with('/', basic_auth: 'foo').and_return fake_response
    subject.execute
  end

  it 'raises an unauthorized error if code is 401' do
    fake_response = double code: 401, parsed_response: {}
    expect(AkamaiApi::CCU::Status::Request).to receive(:get).and_return fake_response
    expect { subject.execute }.to raise_error AkamaiApi::Unauthorized
  end

  it 'returns a StatusResponse' do
    fake_response = double code: 200, parsed_response: {}
    expect(AkamaiApi::CCU::Status::Request).to receive(:get).and_return fake_response
    expect(subject.execute).to be_a AkamaiApi::CCU::Status::Response
  end
end
