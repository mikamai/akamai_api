require 'spec_helper'

describe 'Given I request the current status' do
  context 'and given my login credentials are correct', vcr: { cassette_name: 'ccu/status/successful' } do
    it 'I receive a successful response object' do
      expect(AkamaiApi::Ccu.status).to be_a AkamaiApi::Ccu::StatusResponse
    end
  end

  context 'and given my login credentials are wrong', vcr: { cassette_name: 'ccu/status/unauthorized' } do
    before { AkamaiApi::Ccu.stub auth: { username: 'wrongone', password: 'wrongpass' } }

    it 'an error is raised' do
      expect { AkamaiApi::Ccu.status }.to raise_error AkamaiApi::Ccu::Unauthorized
    end
  end
end
