require 'spec_helper'

module AkamaiApi::ECCU
  describe Tokenizer do

    describe '.split_path' do
      context 'return 7 blocks' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/*.png" }
        it { expect(eccu_tokenizer.tokens.size).to equal 6 }

        it 'and all blocks have the correct type' do
          expect( eccu_tokenizer.tokens[0].type ).to equal :dir
          expect( eccu_tokenizer.tokens[1].type ).to equal :separator
          expect( eccu_tokenizer.tokens[2].type ).to equal :dir
          expect( eccu_tokenizer.tokens[3].type ).to equal :separator
          expect( eccu_tokenizer.tokens[4].type ).to equal :wildcard
          expect( eccu_tokenizer.tokens[5].type ).to equal :extension
        end
      end
    end

  end
end
