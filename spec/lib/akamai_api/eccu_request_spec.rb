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
      let(:fixture) { File.read 'spec/fixtures/eccu/get_info/successful.xml' }

      def soap_body id, verbose
        SoapBody.new do
          integer :fileId, id
          boolean :retrieveContents, verbose
        end
      end

      context 'when calling the ECCU service' do
        it 'sets the specified code and verbosity' do
          body = soap_body(1234567, false).to_s
          savon.expects(:get_info).with(:message => body).returns(fixture)
          EccuRequest.find('1234567')
        end

        it 'sets to return file content if verbose is specified' do
          body = soap_body(1234567, true).to_s
          savon.expects(:get_info).with(:message => body).returns(fixture)
          EccuRequest.find('1234567', :verbose => true)
        end
      end

      it 'correctly assign the exact match' do
        body = soap_body(1234567, false).to_s
        savon.expects(:get_info).with(:message => body).returns(fixture)
        r = EccuRequest.find('1234567')
        r.property[:exact_match].should be_true
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
      it 'returns the detail for each enlisted id even if only one id is returned' do
        EccuRequest.stub :all_ids => "a"
        EccuRequest.should_receive(:find).with('a', anything()).and_return(:a)
        EccuRequest.all.should =~ [:a]
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
        context 'when there is an error' do
          before do
            fixture = File.read 'spec/fixtures/eccu/upload/fault.xml'
            savon.expects(:upload).with(:message => :any).returns(fixture)
          end

          it 'raises an error' do
            expect { EccuRequest.publish '', xml_request_content }.to raise_error Savon::SOAPFault
          end
        end

        context 'when there are no errors' do
          let(:fixture) { File.read 'spec/fixtures/eccu/upload/successful.xml' }

          it 'returns an EccuRequest instance' do
            savon.expects(:upload).with(:message => :any).returns(fixture)
            EccuRequest.publish('', xml_request_content).should be_a Fixnum
          end

          it 'assigns the fields correctly' do
            content = xml_request_content
            body = SoapBody.new do
              string  :filename,          'eccu_request.xml'
              text    :contents,          content
              string  :notes,             'sample notes'
              string  :versionString,     'v2'
              string  :statusChangeEmail, 'foo@foo.com bar@bar.com'
              string  :propertyName,      'foo.com'
              string  :propertyType,      'prop'
              boolean :propertyNameExactMatch, false
            end
            savon.expects(:upload).with(:message => body.to_s).returns(fixture)
            EccuRequest.publish('foo.com', xml_request_content, {
              :file_name => 'eccu_request.xml',
              :notes     => 'sample notes',
              :version   => 'v2',
              :emails    => %w(foo@foo.com bar@bar.com),
              :property_type => 'prop',
              :property_exact_match => false
            })
          end

          it 'assigns a default notes field if no notes are specified' do
            SoapBody.any_instance.stub :string => nil
            SoapBody.any_instance.should_receive(:string).with(:notes, kind_of(String))
            savon.expects(:upload).with(:message => :any).returns(fixture)
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns emails field if specified' do
            SoapBody.any_instance.should_not_receive(:string).with(:statusChangeEmail, anything())
            savon.expects(:upload).with(:message => :any).returns(fixture)
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns the property type to hostheader by default' do
            SoapBody.any_instance.stub :string => nil
            SoapBody.any_instance.should_receive(:string).with(:propertyType, 'hostheader')
            savon.expects(:upload).with(:message => :any).returns(fixture)
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns the property exact match to true by default' do
            SoapBody.any_instance.stub :boolean => nil
            SoapBody.any_instance.should_receive(:boolean).with(:propertyNameExactMatch, true)
            savon.expects(:upload).with(:message => :any).returns(fixture)
            EccuRequest.publish '', xml_request_content
          end
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
        let(:fixture) { File.read 'spec/fixtures/eccu/set_notes/successful.xml' }

        it 'updates the notes field' do
          savon.expects(:set_notes).with(:message => :any).returns(fixture)
          req = EccuRequest.new :code => '1234'
          expect {
            req.update_notes! 'foo'
          }.to change(req, :notes).to 'foo'
        end

        it 'calls the ECCU service using code and notes' do
          body = SoapBody.new do
            integer :fileId, 1234
            string  :notes,  'foo'
          end
          savon.expects(:set_notes).with(:message => body.to_s).returns(fixture)
          EccuRequest.new(:code => '1234').update_notes! 'foo'
        end

        it 'calls the ECCU service and return the service boolean response' do
          savon.expects(:set_notes).with(:message => :any).returns(fixture)
          EccuRequest.new(:code => '1234').update_notes!('foo').should be_true
        end
      end

      describe '#update_email' do
        let(:fixture) { File.read 'spec/fixtures/eccu/set_status_change_email/successful.xml' }

        it 'updates the email field' do
          savon.expects(:set_status_change_email).with(:message => :any).returns(fixture)
          req = EccuRequest.new :code => '1234'
          expect {
            req.update_email! 'foo'
          }.to change(req, :email).to 'foo'
        end

        it 'calls the ECCU service using code and email' do
          body = SoapBody.new do
            integer :fileId,            1234
            string  :statusChangeEmail, 'foo'
          end
          savon.expects(:set_status_change_email).with(:message => body.to_s).returns(fixture)
          EccuRequest.new(:code => '1234').update_email! 'foo'
        end

        it 'calls the ECCU service and return the service boolean response' do
          savon.expects(:set_status_change_email).with(:message => :any).returns(fixture)
          EccuRequest.new(:code => '1234').update_email!('foo').should be_true
        end

        context 'when there is an error' do
          let(:fixture) { File.read 'spec/fixtures/eccu/set_status_change_email/fault.xml' }

          it 'does not update the mail' do
            savon.expects(:set_status_change_email).with(:message => :any).returns(fixture)
            req = EccuRequest.new :code => '1234'
          expect {
            req.update_email! 'foo'
          }.to_not change(req, :email)
          end
        end
      end

      describe '#destroy' do
        let(:fixture) { File.read 'spec/fixtures/eccu/delete/successful.xml' }

        it 'calls the ECCU service using code' do
          body = SoapBody.new do
            integer :fileId, 1234
          end
          savon.expects(:delete).with(:message => body.to_s).returns(fixture)
          EccuRequest.new(:code => '1234').destroy
        end

        it 'calls the ECCU service and return the service boolean response' do
          savon.expects(:delete).with(:message => :any).returns(fixture)
          EccuRequest.new(:code => '1234').destroy.should be_true
        end
      end
    end
  end
end
