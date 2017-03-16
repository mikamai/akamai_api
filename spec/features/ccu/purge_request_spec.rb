require 'spec_helper'

describe 'Given I request to purge an asset' do
  subject { AkamaiApi::CCU }

  let(:estimated_time) { 420 }

  shared_examples 'purge helper' do
    let(:method) { "#{action}_#{type}" }

    it 'responds with a PurgeResponse object' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
        expect(subject.send method, items).to be_a AkamaiApi::CCU::Purge::Response
      end
    end

    it 'raises error when user is not authorized' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/invalid_credentials" do
        expect { subject.send(method, items) }.to raise_error AkamaiApi::Unauthorized
      end
    end

    it 'raises an error when data request is invalid' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/invalid_item" do
        expect { subject.send method, items }.to raise_error AkamaiApi::CCU::Error
      end
    end

    describe 'when data are correct' do
      it 'returns the expected response code' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          expect(subject.send(method, items).code).to eq 201
        end
      end

      it 'returns a successful message' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          expect(subject.send(method, items).message).to eq 'Request accepted.'
        end
      end

      it 'returns a unique purge id' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          expect(subject.send(method, items).purge_id).to eq '12345678-1234-1234-1234-123456789012'
        end
      end

      it 'returns a unique support id' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          expect(subject.send(method, items).support_id).to eq '12345678901234567890-123456789'
        end
      end

      it 'returns the estimated time in seconds' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          expect(subject.send(method, items).estimated_time).to eq estimated_time
        end
      end
    end
  end

  context 'when this asset is an ARL and I want to invalidate it' do
    let(:action) { 'invalidate' }
    let(:type) { 'arl' }
    let(:items) { ['http://www.foo.bar/t.txt'] }

    let(:estimated_time) { 5 }

    it_should_behave_like 'purge helper'
  end

  context 'when this asset is a CPCode and I want to invalidate it' do
    let(:action) { 'invalidate' }
    let(:type) { 'cpcode' }
    let(:items) { ['12345'] }

    it_should_behave_like 'purge helper'
  end

  context 'when this asset is an ARL and I want to remove it' do
    let(:action) { 'remove' }
    let(:type) { 'arl' }
    let(:items) { ['http://www.foo.bar/t.txt'] }

    it_should_behave_like 'purge helper'
  end

  context 'when this asset is a CPCode and I want to remove it' do
    let(:action) { 'remove' }
    let(:type) { 'cpcode' }
    let(:items) { ['12345'] }

    it_should_behave_like 'purge helper'
  end
end
