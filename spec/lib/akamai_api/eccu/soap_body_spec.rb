require 'spec_helper'

describe AkamaiApi::ECCU::SoapBody do
  let(:config) { double :env_namespace => '', :soap_version => '2' }

  describe '#string' do
    before { subject.string 'foo', 'sample' }

    it 'adds a string field' do
      expect(subject.to_s).to match /<foo.*>sample<\/foo>/
    end

    it 'sets the correct type attribute' do
      expect(subject.to_s).to match /<foo xsi:type=\"xsd:string\">/
    end
  end

  describe '#array' do
    before { subject.array 'foo', ['a', 'b'] }

    it 'adds an array field' do
      expect(subject.to_s).to match /<foo.*><item>a<\/item><item>b<\/item><\/foo>/
    end

    it 'sets the correct type attribute' do
      expect(subject.to_s).to match /<foo.*xsi:type="wsdl:ArrayOfString"/
    end

    it 'sets the correct arrayType attribute' do
      expect(subject.to_s).to match /<foo.*soapenc:arrayType="xsd:string\[2\]"/
    end
  end

  describe '#text' do
    before { subject.text 'foo', 'foo' }

    it 'adds a base64 encoded string field' do
      match = subject.to_s.match /<foo.*>(.+)<\/foo>/m
      expect(Base64.decode64 match[1]).to eq 'foo'
    end

    it 'sets the correct type attribute' do
      expect(subject.to_s).to match /<foo.*xsi:type="xsd:base64Binary/
    end
  end
end
