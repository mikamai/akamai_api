require 'spec_helper'

module AkamaiApi::ECCU
  describe Tokenizer do

    describe '.tokenize' do
      context 'return 8 tokens' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/**/*.png" }
        it { expect(eccu_tokenizer.tokens.size).to equal 8 }

        it 'and all tokens have the correct type' do
          expect( eccu_tokenizer.tokens[0].type ).to equal :dir
          expect( eccu_tokenizer.tokens[1].type ).to equal :separator
          expect( eccu_tokenizer.tokens[2].type ).to equal :dir
          expect( eccu_tokenizer.tokens[3].type ).to equal :separator
          expect( eccu_tokenizer.tokens[4].type ).to equal :double_wildcard
          expect( eccu_tokenizer.tokens[5].type ).to equal :separator
          expect( eccu_tokenizer.tokens[6].type ).to equal :wildcard
          expect( eccu_tokenizer.tokens[7].type ).to equal :extension
        end
      end

      context 'last token is a :filename' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/**/test.png" }
        it { expect( eccu_tokenizer.tokens.last.type ).to equal :filename }
      end

      context 'single word is a :filename' do
        let(:eccu_tokenizer) { Tokenizer.new "foo" }
        it { expect( eccu_tokenizer.tokens.first.type ).to equal :filename }
      end

      context 'single word with end / is a :dir' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/" }
        it { expect( eccu_tokenizer.tokens.first.type ).to equal :dir }
      end

    end

  end
end
