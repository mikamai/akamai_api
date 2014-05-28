require 'spec_helper'

describe 'Given I request the current status' do
  context 'and given my login credentials are correct', vcr: { cassette_name: 'akamai_api_ccu_status/valid_credentials' } do
    it 'I receive a successful response object' do
      expect(AkamaiApi::CCU.status).to be_a AkamaiApi::CCU::Status::Response
    end
  end

  context 'and given my login credentials are wrong', vcr: { cassette_name: 'akamai_api_ccu_status/invalid_credentials' } do
    before { AkamaiApi.stub auth: { username: 'foo', password: 'bar' } }

    it 'an error is raised' do
      expect { AkamaiApi::CCU.status }.to raise_error AkamaiApi::Unauthorized
    end
  end
end
