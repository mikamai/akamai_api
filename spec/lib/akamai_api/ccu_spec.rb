require 'spec_helper'

module AkamaiApi
  describe Ccu do
    include SavonTester

    before do
      savon.expects('wsdl:purgeRequest').returns :body => Savon::Spec::Fixture['purge_request', 'success']
      stub_savon_model Ccu
    end

    shared_examples 'purge helper' do
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
        %w(invalidate remove).each do |action|
          expect {
            Ccu.purge action, :cpcode, '1234'
          }.to_not raise_error
        end
        expect { Ccu.purge :sss, :cpcode, '12345' }.to raise_error
      end

      it 'type is not allowed' do
        %w(cpcode arl).each do |type|
          expect {
            Ccu.purge :remove, type, '12345'
          }.to_not raise_error
        end
        expect { Ccu.purge :remove, :foo, '12345' }.to raise_error
      end

      it 'domain is specified and not allowed' do
        %w(production staging).each do |domain|
          expect { Ccu.purge :remove, :arl, 'foo', :domain => domain }.to_not raise_error
        end
        expect { Ccu.purge :remove, :arl, 'foo', :domain => :foo }.to raise_error
      end
    end

    describe '#purge request arguments' do
      it 'should include user and password' do
        soap_body = SoapBody.any_instance
        soap_body.stub :string => ''
        soap_body.should_receive(:string).with :name, AkamaiApi.config[:auth].first
        soap_body.should_receive(:string).with :pwd, AkamaiApi.config[:auth].last
        Ccu.purge :remove, :arl, 'foo'
      end

      describe 'options' do
        before { SoapBody.any_instance.stub :array => '' }

        it 'include action and type' do
          SoapBody.any_instance.should_receive(:array).with(:opt, kind_of(Array)) do |name, array|
            array.should include 'type=arl'
            array.should include 'action=remove'
          end
          Ccu.purge :remove, :arl, 'foo'
        end

        describe 'domain' do
          it 'is not included by default' do
            SoapBody.any_instance.should_receive(:array).with(:opt, kind_of(Array)) do |name, array|
              array.detect { |s| s =~ /^domain/ }.should be_nil
            end
            Ccu.purge :remove, :arl, 'foo'
          end

          it 'is included if specified' do
            SoapBody.any_instance.should_receive(:array).with(:opt, kind_of(Array)) do |name, array|
              array.should include 'domain=production'
            end
            Ccu.purge :remove, :arl, 'foo', :domain => 'production'
          end
        end

        describe 'email' do
          it 'is not included by default' do
            SoapBody.any_instance.should_receive(:array).with(:opt, kind_of(Array)) do |name, array|
              array.detect { |s| s =~ /^email/ }.should be_nil
            end
            Ccu.purge :remove, :arl, 'foo'
          end

          it 'is included if specified' do
            SoapBody.any_instance.should_receive(:array).with(:opt, kind_of(Array)) do |name, array|
              array.should include 'email-notification=foo@foo.com,pip@pip.com'
            end
            Ccu.purge :remove, :arl, 'foo', :email => ['foo@foo.com', 'pip@pip.com']
          end
        end
      end
    end
  end
end