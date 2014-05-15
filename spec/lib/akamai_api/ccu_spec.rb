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
      it 'responds with a CcuResponse object' do
        VCR.use_cassette "ccu/#{method}/successful" do
          Ccu.send(method, items).should be_a CcuResponse
        end
      end

      it 'raises error when user is not authorized' do
        VCR.use_cassette "ccu/#{method}/unauthorized" do
          expect { Ccu.send(method, items) }.to raise_error AkamaiApi::Ccu::Unauthorized
        end
      end

      it 'returns a different response when data are invalid' do
        VCR.use_cassette "ccu/#{method}/forbidden" do
          response = Ccu.send(method, items)
          expect(response).to be_a CcuResponse
          expect(response.code).to eq 403
        end
      end

      describe 'when data are correct' do
        it 'returns the expected response code' do
          VCR.use_cassette "ccu/#{method}/successful" do
            Ccu.send(method, items).code.should == 201
          end
        end

        it 'returns a successful message' do
          VCR.use_cassette "ccu/#{method}/successful" do
            Ccu.send(method, items).message.should == 'Request accepted.'
          end
        end

        it 'returns a unique purge id' do
          VCR.use_cassette "ccu/#{method}/successful" do
            Ccu.send(method, items).purge_id.should == '12345678-1234-1234-1234-123456789012'
          end
        end

        it 'returns a unique support id' do
          VCR.use_cassette "ccu/#{method}/successful" do
            Ccu.send(method, items).support_id.should == '12345678901234567890-123456789'
          end
        end

        it 'returns the estimated time in seconds' do
          VCR.use_cassette "ccu/#{method}/successful" do
            Ccu.send(method, items).estimated_time.should == 420
          end
        end
      end
    end

    context '#invalidate_arl' do
      let(:method) { 'invalidate_arl' }
      let(:items) { ['http://www.foo.bar/t.txt'] }

      it_should_behave_like 'purge helper'
    end

    context '#invalidate_cpcode' do
      let(:method) { 'invalidate_cpcode' }
      let(:items) { ['12345'] }

      it_should_behave_like 'purge helper'
    end

    context '#remove_arl' do
      let(:method) { 'remove_arl' }
      let(:items) { ['http://www.foo.bar/t.txt'] }

      it_should_behave_like 'purge helper'
    end

    context '#remove_cpcode' do
      let(:method) { 'remove_cpcode' }
      let(:items) { ['12345'] }

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
