require 'spec_helper'

module AkamaiApi
  describe ECCUParser do

    describe 'initialize' do
      context 'create tokenizer' do
        let(:parser){ ECCUParser.new "foo/bar/*.png" }
        it{ expect( parser.tokenizer.class.name ).to eq( "AkamaiApi::ECCU::Tokenizer" ) }
      end
    end

    describe 'raises' do
      context 'error on empty string' do
        let(:parser){ ECCUParser.new "" }
        it { expect{ parser.xml }.to raise_error "Expression can't be empty" }
      end
      context '* as not allowed extension' do
        let(:parser){ ECCUParser.new "foo/*.*" }
        it { expect{ parser.xml }.to raise_error }
      end
      context '. as not allowed dir' do
        let(:parser){ ECCUParser.new "./test.png" }
        it { expect{ parser.xml }.to raise_error }
      end
      context '.. as not allowed dir' do
        let(:parser){ ECCUParser.new "../test.png" }
        it { expect{ parser.xml }.to raise_error }
      end
      context 'Extension will be the last element ' do
        let(:parser){ ECCUParser.new "foo/*.png/" }
        it { expect{ parser.xml }.to raise_error "Extension will be the last element" }
      end
    end

  end
end
