module AkamaiApi
  describe SoapBody do
    let(:config) { double :env_namespace => '', :soap_version => '2' }
    subject { SoapBody.new Savon::SOAP::XML.new config}

    it 'adds the soapenc ns' do
      Savon::SOAP::XML.new(config).namespaces.should_not include 'xmlns:soapenc'
      subject.soap.namespaces.should include 'xmlns:soapenc'
    end

    describe '#string' do
      before { subject.string 'foo', 'sample' }

      it 'adds a string field' do
        subject.body[:foo].should == 'sample'
      end

      it 'sets the correct type attribute' do
        subject.body_attributes[:foo]['xsi:type'].should == 'xsd:string'
      end
    end

    describe '#array' do
      before { subject.array 'foo', ['a', 'b'] }

      it 'adds an array field' do
        subject.body[:foo].should == { 'item' => ['a', 'b'] }
      end

      it 'sets the correct type attribute' do
        subject.body_attributes[:foo]['xsi:type'].should == 'wsdl:ArrayOfString'
      end

      it 'sets the correct arrayType attribute' do
        subject.body_attributes[:foo]['soapenc:arrayType'].should == 'xsd:string[2]'
      end
    end

    describe '#text' do
      before { subject.text 'foo', 'foo' }

      it 'adds a base64 encoded string field' do
        Base64.decode64(subject.body[:foo]).should == 'foo'
      end

      it 'sets the correct type attribute' do
        subject.body_attributes[:foo]['xsi:type'].should == 'xsd:base64Binary'
      end
    end
  end
end