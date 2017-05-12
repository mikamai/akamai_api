require 'spec_helper'

describe AkamaiApi::CCU do
  subject { AkamaiApi::CCU }

  %w(invalidate remove).each do |action|
    describe "##{action}" do
      it 'raises error if less than 2 arguments are given' do
        expect { subject.send action, 'foo' }.to raise_error ArgumentError
      end

      it 'delegates to #purge with the given type' do
        expect(subject).to receive(:purge).with(action.to_sym, :cpcode, 'foo', domain: 'asd').and_return 'bar'
        expect(subject.send action, :cpcode, 'foo', domain: 'asd').to eq 'bar'
      end
    end

    %w(arl cpcode).each do |type|
      describe "##{action}_#{type}" do
        let(:method) { "#{action}_#{type}" }

        it 'raises error if less than 1 argument is given' do
          expect { subject.send method }.to raise_error ArgumentError
        end

        it 'delegates to #purge with the given items' do
          expect(subject).to receive(:purge).with(action.to_sym, type.to_sym, 'foo', domain: 'asd').and_return 'bar'
          expect(subject.send method, 'foo', domain: 'asd').to eq 'bar'
        end
      end
    end
  end

  describe '#purge' do
    it 'delegates to Purge::Request' do
      fake_request = double
      expect(fake_request).to receive(:execute).with('baz').and_return 'quiz'
      expect(AkamaiApi::CCU::Purge::Request).to receive(:new).with('foo', 'bar', domain: 'asd').
                                               and_return fake_request
      expect(subject.purge 'foo', 'bar', 'baz', domain: 'asd').to eq 'quiz'
    end

    describe 'raises an error when' do
      it 'action is not allowed' do
        expect { subject.purge :sss, :cpcode, '12345' }.to raise_error AkamaiApi::CCU::UnrecognizedOption
      end

      it 'type is not allowed' do
        expect { subject.purge :remove, :foo, '12345' }.to raise_error AkamaiApi::CCU::UnrecognizedOption
      end

      it 'domain is specified and not allowed' do
        expect { subject.purge :remove, :arl, 'foo', :domain => :foo }.to raise_error
      end
    end
  end
end
