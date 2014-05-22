require 'spec_helper'

describe 'Given I request to purge an asset' do
  subject { AkamaiApi::Ccu }

  shared_examples 'purge helper' do
    let(:method) { "#{action}_#{type}" }

    it 'responds with a PurgeResponse object' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
        subject.send(method, items).should be_a AkamaiApi::Ccu::Purge::Response
      end
    end

    it 'raises error when user is not authorized' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/invalid_credentials" do
        AkamaiApi.stub auth: { username: 'foo', password: 'bar' }
        expect { subject.send(method, items) }.to raise_error AkamaiApi::Unauthorized
      end
    end

    it 'returns a different response when data are invalid' do
      VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/invalid_item" do
        response = subject.send(method, items)
        expect(response).to be_a AkamaiApi::Ccu::Purge::Response
        expect(response.code).to eq 403
      end
    end

    describe 'when data are correct' do
      it 'returns the expected response code' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          subject.send(method, items).code.should == 201
        end
      end

      it 'returns a successful message' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          subject.send(method, items).message.should == 'Request accepted.'
        end
      end

      it 'returns a unique purge id' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          subject.send(method, items).purge_id.should == '12345678-1234-1234-1234-123456789012'
        end
      end

      it 'returns a unique support id' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          subject.send(method, items).support_id.should == '12345678901234567890-123456789'
        end
      end

      it 'returns the estimated time in seconds' do
        VCR.use_cassette "akamai_api_ccu_#{type}_#{action}/single_item" do
          subject.send(method, items).estimated_time.should == 420
        end
      end
    end
  end

  context 'when this asset is an ARL and I want to invalidate it' do
    let(:action) { 'invalidate' }
    let(:type) { 'arl' }
    let(:items) { ['http://www.foo.bar/t.txt'] }

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
