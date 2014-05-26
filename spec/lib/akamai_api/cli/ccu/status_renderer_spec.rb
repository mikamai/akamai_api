require 'spec_helper'

module AkamaiApi
  describe CLI::Ccu::StatusRenderer do
    subject { CLI::Ccu::StatusRenderer.new Ccu::Status::Response.new({}) }

    describe '#render' do
      it 'returns a string' do
        expect(subject.render).to be_a String
      end

      it 'delegates to #render_status if response is a Status::Response' do
        expect(subject).to receive(:queue_status)
        subject.render
      end

      it 'delegates to #render_purge_status if response is a PurgeStatus::Response' do
        subject = CLI::Ccu::StatusRenderer.new Ccu::PurgeStatus::SuccessfulResponse.new({})
        expect(subject).to receive(:purge_status)
        subject.render
      end
    end

    it '#render_purge_status delegates to #render_successful_purge_status for success response' do
      subject = CLI::Ccu::StatusRenderer.new Ccu::PurgeStatus::SuccessfulResponse.new({})
      expect(subject).to receive :successful_purge
      subject.purge_status
    end

    it '#render_purge_status delegates to #render_not_found_purge_status for not foundresponse' do
      subject = CLI::Ccu::StatusRenderer.new Ccu::PurgeStatus::NotFoundResponse.new({})
      expect(subject).to receive :not_found_purge
      subject.purge_status
    end
  end
end
