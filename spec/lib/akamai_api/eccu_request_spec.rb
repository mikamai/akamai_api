require 'spec_helper'

module AkamaiApi
  describe EccuRequest do
    include SavonTester

    before { stub_savon_model EccuRequest }

    describe '::all_ids' do
      before { savon.expects('getIds').returns(:success) }

      it 'returns the id list of all available requests' do
        EccuRequest.all_ids.should =~ ['42994282', '43000154']
      end
    end

    describe '::find' do
      before { savon.expects('getInfo').returns(:success) }

      context 'when calling the ECCU service' do
        it 'sets the specified code' do
          SoapBody.any_instance.should_receive(:integer).with :fileId, 1234567
          EccuRequest.find('1234567')
        end

        it 'sets to not return file content by default' do
          SoapBody.any_instance.should_receive(:boolean).with :retrieveContents, false
          EccuRequest.find('1234567')
        end

        it 'sets to return file content if verbose is specified' do
          SoapBody.any_instance.should_receive(:boolean).with :retrieveContents, true
          EccuRequest.find('1234567', :verbose => true)
        end
      end

      it 'correctly assign the exact match' do
        r = EccuRequest.find('1234567')
        r.property[:exact_match].should be_true
      end
    end

    describe '::last' do
      it 'find the most recent entry' do
        EccuRequest.stub! :all_ids => %w(a b)
        EccuRequest.should_receive(:find).with('b', anything()).and_return :a
        EccuRequest.last.should == :a
      end
    end

    describe '::first' do
      it 'find the oldest entry' do
        EccuRequest.stub! :all_ids => %w(a b)
        EccuRequest.should_receive(:find).with('a', anything()).and_return :a
        EccuRequest.first.should == :a
      end
    end

    describe '::all' do
      it 'returns the detail for each enlisted id' do
        EccuRequest.stub! :all_ids => %w(a b)
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
        context 'when there is an error' do
          before { savon.expects('upload').returns(:fault) }

          it 'raises an error' do
            expect { EccuRequest.publish '', xml_request_content }
          end
        end

        context 'when there are no errors' do
          before { savon.expects('upload').returns(:success) }

          it 'returns an EccuRequest instance' do
            EccuRequest.publish('', xml_request_content).should be_a Fixnum
          end

          it 'assigns the fields correctly' do
            soap_body = SoapBody.any_instance
            soap_body.should_receive(:string).with :filename, 'eccu_request.xml'
            soap_body.should_receive(:text).with   :contents, xml_request_content
            soap_body.should_receive(:string).with :notes,    'sample notes'
            soap_body.should_receive(:string).with :versionString, 'v2'
            soap_body.should_receive(:string).with :statusChangeEmail, 'foo@foo.com bar@bar.com'
            soap_body.should_receive(:string).with :propertyName, 'foo.com bar.com'
            soap_body.should_receive(:string).with :propertyType, 'prop'
            soap_body.should_receive(:boolean).with :propertyNameExactMatch, false
            EccuRequest.publish(%w(foo.com bar.com), xml_request_content, {
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
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns emails field if specified' do
            SoapBody.any_instance.should_not_receive(:string).with(:statusChangeEmail, anything())
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns the property type to hostheader by default' do
            SoapBody.any_instance.stub :string => nil
            SoapBody.any_instance.should_receive(:string).with(:propertyType, 'hostheader')
            EccuRequest.publish '', xml_request_content
          end

          it 'assigns the property exact match to true by default' do
            SoapBody.any_instance.stub :boolean => nil
            SoapBody.any_instance.should_receive(:boolean).with(:propertyNameExactMatch, true)
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
        before { savon.expects('setNotes').returns(:success) }

        it 'updates the notes field' do
          req = EccuRequest.new :code => '1234'
          expect {
            req.update_notes! 'foo'
          }.to change(req, :notes).to 'foo'
        end

        it 'calls the ECCU service using code and notes' do
          req = EccuRequest.new :code => '1234'
          soap_body = SoapBody.any_instance
          soap_body.should_receive(:integer).with :fileId, 1234
          soap_body.should_receive(:string).with  :notes, 'foo'
          req.update_notes! 'foo'
        end

        it 'calls the ECCU service and return the service boolean response' do
          req = EccuRequest.new :code => '1234'
          req.update_notes!('foo').should == true
        end
      end

      describe '#update_email' do
        before { savon.expects('setStatusChangeEmail').returns(:success) }

        it 'updates the email field' do
          req = EccuRequest.new :code => '1234'
          expect {
            req.update_email! 'foo'
          }.to change(req, :email).to 'foo'
        end

        it 'calls the ECCU service using code and email' do
          req = EccuRequest.new :code => '1234'
          soap_body = SoapBody.any_instance
          soap_body.should_receive(:integer).with :fileId, 1234
          soap_body.should_receive(:string).with  :statusChangeEmail, 'foo'
          req.update_email! 'foo'
        end

        it 'calls the ECCU service and return the service boolean response' do
          req = EccuRequest.new :code => '1234'
          req.update_email!('foo').should == true
        end
      end

      describe '#destroy' do
        before { savon.expects('delete').returns(:success) }

        it 'calls the ECCU service using code' do
          req = EccuRequest.new :code => '1234'
          soap_body = SoapBody.any_instance
          soap_body.should_receive(:integer).with :fileId, 1234
          req.destroy
        end

        it 'calls the ECCU service and return the service boolean response' do
          req = EccuRequest.new :code => '1234'
          req.destroy.should == true
        end
      end
    end
  end
end