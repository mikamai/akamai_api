require 'spec_helper'

module AkamaiApi
  describe ECCUParser do

    describe 'initialize' do
      context 'create tokenizer' do
        let(:parser){ ECCUParser.new "foo/bar/*.png" }
        it{ expect( parser.tokenizer.class.name ).to eq( "AkamaiApi::ECCU::Tokenizer" ) }
      end
    end

    describe '.xml' do

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

      context 'only 1 recursive-dirs tag' do
        let(:parser){ ECCUParser.new "foo/" }
        it{ expect( parser.xml ).to eq( "<eccu><match:recursive-dirs value=\"foo\"><revalidate>now</revalidate></match:recursive-dirs></eccu>" ) }
      end

    end
  end
end
