require 'spec_helper'

describe AkamaiApi::Ccu do
  subject { AkamaiApi::Ccu }

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
    it 'delegates to PurgeRequest' do
      fake_request = double
      expect(fake_request).to receive(:execute).with('baz').and_return 'quiz'
      expect(AkamaiApi::Ccu::PurgeRequest).to receive(:new).with('foo', 'bar', domain: 'asd').
                                               and_return fake_request
      expect(subject.purge 'foo', 'bar', 'baz', domain: 'asd').to eq 'quiz'
    end

    describe 'raises an error when' do
      it 'action is not allowed' do
        expect { subject.purge :sss, :cpcode, '12345' }.to raise_error AkamaiApi::Ccu::UnrecognizedOption
      end

      it 'type is not allowed' do
        expect { subject.purge :remove, :foo, '12345' }.to raise_error AkamaiApi::Ccu::UnrecognizedOption
      end

      it 'domain is specified and not allowed' do
        expect { subject.purge :remove, :arl, 'foo', :domain => :foo }.to raise_error
      end
    end
  end

  describe '#status' do
    context "when no argument is given" do
      it "delegates to Status request instance" do
        expect(AkamaiApi::Ccu::StatusRequest).to receive(:new).and_return double execute: 'foo'
        expect(subject.status).to eq 'foo'
      end
    end

    context "when a progress uri is passed as argument" do
      it "delegates to PurgeStatus request instance" do
        fake_instance = double
        expect(AkamaiApi::Ccu::PurgeStatus::Request).to receive(:new).and_return fake_instance
        expect(fake_instance).to receive(:execute).with('foo').and_return 'asd'
        expect(subject.status 'foo').to eq 'asd'
      end
    end
  end
end
