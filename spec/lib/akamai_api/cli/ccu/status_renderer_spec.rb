require 'spec_helper'

module AkamaiApi
  describe CLI::CCU::StatusRenderer do
    subject { CLI::CCU::StatusRenderer.new CCU::Status::Response.new({}) }

    describe '#render' do
      it 'returns a string' do
        expect(subject.render).to be_a String
      end

      it 'delegates to #render_status if response is a Status::Response' do
        expect(subject).to receive(:queue_status)
        subject.render
      end

      it 'delegates to #render_purge_status if response is a PurgeStatus::Response' do
        subject = CLI::CCU::StatusRenderer.new CCU::PurgeStatus::Response.new({})
        expect(subject).to receive(:purge_status)
        subject.render
      end
    end
  end
end
