require 'spec_helper'

module AkamaiApi
  describe EccuRequest do
    include Savon::SpecHelper

    before(:all) { savon.mock! }
    after(:all)  { savon.unmock! }

    describe '::all_ids' do
      before do
        fixture = File.read 'spec/fixtures/eccu/get_ids/successful.xml'
        savon.expects(:get_ids).returns(fixture)
      end

      it 'returns the id list of all available requests' do
        EccuRequest.all_ids.should =~ ['42994282', '43000154']
      end
    end

    describe '::find' do
      subject { EccuRequest }

      it 'delegates to FindRequest' do
        fake_request = double
        expect(fake_request).to receive(:execute).with(true).and_return AkamaiApi::Eccu::FindResponse.new({})
        expect(AkamaiApi::Eccu::FindRequest).to receive(:new).with('1234').and_return fake_request
        subject.find '1234'
      end

      it "returns an EccuRequest" do
        response = AkamaiApi::Eccu::FindResponse.new({})
        expect_any_instance_of(AkamaiApi::Eccu::FindRequest).to receive(:execute).and_return response
        subject.find '1234'
      end

      {
        file:        :file,
        status:      :status,
        code:        :code,
        notes:       :notes,
        property:    :property,
        email:       :email,
        upload_date: :uploaded_at,
        uploaded_by: :uploaded_by,
        version:     :version
      }.each do |local_name, remote_name|
        it "maps response '#{remote_name}' to '#{local_name}'" do
          response = AkamaiApi::Eccu::FindResponse.new({})
          response.stub remote_name => "foobarbaz"
          expect_any_instance_of(AkamaiApi::Eccu::FindRequest).to receive(:execute).and_return response
          expect(subject.find('1234').send local_name).to eq "foobarbaz"
        end
      end
    end

    describe '::last' do
      it 'find the most recent entry' do
        EccuRequest.stub :all_ids => %w(a b)
        EccuRequest.should_receive(:find).with('b', anything()).and_return :a
        EccuRequest.last.should == :a
      end
    end

    describe '::first' do
      it 'find the oldest entry' do
        EccuRequest.stub :all_ids => %w(a b)
        EccuRequest.should_receive(:find).with('a', anything()).and_return :a
        EccuRequest.first.should == :a
      end
    end

    describe '::all' do
      it 'returns the detail for each enlisted id' do
        EccuRequest.stub :all_ids => %w(a b)
        EccuRequest.should_receive(:find).with('a', anything()).and_return(:a)
        EccuRequest.should_receive(:find).with('b', anything()).and_return(:b)
        EccuRequest.all.should =~ [:a, :b]
      end
    end

    describe 'publishing' do
      let(:xml_request) { File.expand_path "../../../fixtures/eccu_request.xml", __FILE__ }
      let(:xml_request_content) { File.read xml_request }

      describe '::publish_file' do
        it 'calls publish with the content of the specified file' do
          args = {}
          EccuRequest.should_receive(:publish).with('foo', xml_request_content, args)
          EccuRequest.publish_file('foo', xml_request, args)
        end
      end

      describe '::publish' do
        let(:subject) { EccuRequest }

        it 'does not alter given arguments' do
          expect_any_instance_of(AkamaiApi::Eccu::PublishRequest).to receive :execute
          args = { property_type: 'asd' }
          expect { subject.publish 'foo.com', 'asd', args }.to_not change args, :count
        end

        it 'correctly builds a PublishRequest' do
          expected_args = ['foo.com', { type: 'hostheader', exact_match: true }]
          expect(AkamaiApi::Eccu::PublishRequest).to receive(:new).with(*expected_args).and_return double(execute: nil)
          subject.publish 'foo.com', 'asd', property_type: 'hostheader', property_exact_match: true
        end

        it 'does not pass nil values to constructor arguments' do
          expect(AkamaiApi::Eccu::PublishRequest).to receive(:new).with('foo.com', {}).and_return double(execute: nil)
          subject.publish 'foo.com', 'asd', property_type: nil, property_exact_match: nil
        end

        it 'delegates to PublishRequest#execute' do
          expect_any_instance_of(AkamaiApi::Eccu::PublishRequest).to receive(:execute).and_return 1
          expect(subject.publish 'foo.com', 'asd').to eq 1
        end

        it 'pass content and given arguments to execute' do
          expect_any_instance_of(AkamaiApi::Eccu::PublishRequest).to receive(:execute).with 'asd', emails: 'foo@bar.com'
          subject.publish 'foo.com', 'asd', emails: 'foo@bar.com'
        end

        it 'removed unnecessary arguments when calling execute' do
          expect_any_instance_of(AkamaiApi::Eccu::PublishRequest).to receive(:execute).with 'asd', emails: 'foo@bar.com'
          subject.publish 'foo.com', 'asd', emails: 'foo@bar.com', property_exact_match: false
        end
      end
    end

    describe 'instance' do
      describe 'constructor' do
        it 'assigns the attributes hash to the accessors' do
          req = EccuRequest.new :status => 'foo', :notes => 'bar'
          req.status.should == 'foo'
          req.notes.should == 'bar'
        end
      end

      describe '#update_notes!' do
        subject { EccuRequest.new code: '1234' }

        it 'delegates to UpdateNotesRequest' do
          fake_request = double
          expect(fake_request).to receive(:execute).with('foo').and_return true
          expect(AkamaiApi::Eccu::UpdateNotesRequest).to receive(:new).with('1234').and_return fake_request
          subject.update_notes! 'foo'
        end

        context 'when the update is successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::UpdateNotesRequest).to receive(:execute).and_return true
          end

          it "returns true" do
            expect(subject.update_notes! 'foo').to be_true
          end

          it "updates notes attribute" do
            expect { subject.update_notes! 'foo' }.to change(subject, :notes).to 'foo'
          end
        end

        context 'when the update is not successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::UpdateNotesRequest).to receive(:execute).and_return false
          end

          it "returns false" do
            expect(subject.update_notes! 'foo').to be_false
          end

          it "does not update the notes attribute" do
            expect { subject.update_notes! 'foo' }.to_not change(subject, :notes).to 'foo'
          end
        end
      end

      describe '#update_email!' do
        subject { EccuRequest.new code: '1234' }

        it 'delegates to UpdateEmailRequest' do
          fake_request = double
          expect(fake_request).to receive(:execute).with('foo').and_return true
          expect(AkamaiApi::Eccu::UpdateEmailRequest).to receive(:new).with('1234').and_return fake_request
          subject.update_email! 'foo'
        end

        context 'when the update is successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::UpdateEmailRequest).to receive(:execute).and_return true
          end

          it "returns true" do
            expect(subject.update_email! 'foo').to be_true
          end

          it "updates notes attribute" do
            expect { subject.update_email! 'foo' }.to change(subject, :email).to 'foo'
          end
        end

        context 'when the update is not successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::UpdateEmailRequest).to receive(:execute).and_return false
          end

          it "returns false" do
            expect(subject.update_email! 'foo').to be_false
          end

          it "does not update the email attribute" do
            expect { subject.update_email! 'foo' }.to_not change(subject, :email).to 'foo'
          end
        end
      end

      describe '#destroy' do
        subject { EccuRequest.new code: '1234' }

        it 'delegates to DestroyRequest' do
          fake_request = double
          expect(fake_request).to receive(:execute).and_return true
          expect(AkamaiApi::Eccu::DestroyRequest).to receive(:new).with('1234').and_return fake_request
          subject.destroy
        end

        context 'when the update is successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::DestroyRequest).to receive(:execute).and_return true
          end

          it "returns true" do
            expect(subject.destroy).to be_true
          end
        end

        context 'when the update is not successful' do
          before do
            expect_any_instance_of(AkamaiApi::Eccu::DestroyRequest).to receive(:execute).and_return false
          end

          it "returns false" do
            expect(subject.destroy).to be_false
          end
        end
      end
    end
  end
end
