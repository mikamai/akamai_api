require 'spec_helper'

module AkamaiApi
  describe Ccu do
    include Savon::SpecHelper

    before(:all) { savon.mock! }
    after(:all)  { savon.unmock! }

    let(:fixture) { File.read 'spec/fixtures/ccu/successful_purge.xml' }

    def soap_body method, *uris
      method_parts = method.split('_')
      options = ["action=#{method_parts.first}", "type=#{method_parts.last}"]
      SoapBody.new do
        string :name,    AkamaiApi.config[:auth].first
        string :pwd,     AkamaiApi.config[:auth].last
        string :network, ''
        array  :opt,     options
        array  :uri,     uris
      end
    end

    shared_examples 'purge helper' do
      before do
        body = soap_body(method, '12345').to_s
        savon.expects(:purge_request).with(:message => body).returns(fixture)
      end

      it 'responds with a CcuResponse object' do
        Ccu.send(method, '12345').should be_a CcuResponse
      end

      context 'when data are correct' do
        it 'returns the expected response code' do
          Ccu.send(method, '12345').code.should == 100
        end

        it 'returns a successful message' do
          Ccu.send(method, '12345').message.should == 'Success.'
        end

        it 'returns a unique session id' do
          Ccu.send(method, '12345').session_id.should == '97870328-018c-11e2-aabc-489beabc489b'
        end

        it 'returns the estimated time in seconds' do
          Ccu.send(method, '12345').estimated_time.should == 420
        end
      end
    end

    context '#invalidate_arl' do
      let(:method) { 'invalidate_arl' }
      it_should_behave_like 'purge helper'
    end

    context '#invalidate_cpcode' do
      let(:method) { 'invalidate_cpcode' }
      it_should_behave_like 'purge helper'
    end

    context '#remove_arl' do
      let(:method) { 'remove_arl' }
      it_should_behave_like 'purge helper'
    end

    context '#remove_cpcode' do
      let(:method) { 'remove_cpcode' }
      it_should_behave_like 'purge helper'
    end

    describe '#purge raises an error when' do
      it 'action is not allowed' do
        expect { Ccu.purge :sss, :cpcode, '12345' }.to raise_error Ccu::UnrecognizedOption
      end

      it 'type is not allowed' do
        expect { Ccu.purge :remove, :foo, '12345' }.to raise_error Ccu::UnrecognizedOption
      end

      it 'domain is specified and not allowed' do
        expect { Ccu.purge :remove, :arl, 'foo', :domain => :foo }.to raise_error
      end
    end
  end
end