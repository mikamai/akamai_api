require 'spec_helper'

module AkamaiApi::ECCU
  describe Tokenizer do

    describe '.tokenize' do

      context 'with empty expression' do
        let(:tokenizer) { Tokenizer.new "" }
        it 'return 0 tokens' do
          expect( tokenizer.tokens.size ).to equal 0
        end

        it '.current_token return nil' do
          expect( tokenizer.current_token ).to be_nil
        end
        it '.look_next_token return nil' do
          expect( tokenizer.look_next_token ).to be_nil
        end
        it '.next_token return nil' do
          expect( tokenizer.next_token ).to be_nil
        end
      end

      context 'with correct expression' do
        let(:tokenizer) { Tokenizer.new "foo/bar/**/*.png" }
        it 'return 8 tokens' do
          expect(tokenizer.tokens.size).to equal 8
        end

        it 'and all tokens have the correct type' do
          expect( tokenizer.tokens[0].type ).to equal :dir
          expect( tokenizer.tokens[1].type ).to equal :separator
          expect( tokenizer.tokens[2].type ).to equal :dir
          expect( tokenizer.tokens[3].type ).to equal :separator
          expect( tokenizer.tokens[4].type ).to equal :double_wildcard
          expect( tokenizer.tokens[5].type ).to equal :separator
          expect( tokenizer.tokens[6].type ).to equal :wildcard
          expect( tokenizer.tokens[7].type ).to equal :extension
        end

        it '.current_token return nil initially' do
          expect( tokenizer.current_token ).to be_nil
        end
        it '.current_token return a Token object after call .next_token' do
          tokenizer.next_token
          expect( tokenizer.current_token.class.name ).to eq "AkamaiApi::ECCU::Token"
        end
        it '.next_token return a Token object' do
          expect( tokenizer.next_token.class.name ).to eq "AkamaiApi::ECCU::Token"
        end
        it '.look_next_token return a Token object' do
          expect( tokenizer.look_next_token.class.name ).to eq "AkamaiApi::ECCU::Token"
        end
        it '.look_next_token after all token cycles return nil' do
          tokenizer.tokens.size.times do
            tokenizer.next_token
          end
          expect( tokenizer.look_next_token ).to be_nil
        end

        context 'expression not tokenizable' do
          it { expect{ Tokenizer.new('foo/***') }.to raise_error }
        end
      end

      context 'last token is a :filename' do
        let(:tokenizer) { Tokenizer.new "foo/bar/**/test.png" }
        it { expect( tokenizer.tokens.last.type ).to equal :filename }
      end

      context 'single word is a :filename' do
        let(:tokenizer) { Tokenizer.new "foo" }
        it { expect( tokenizer.tokens.first.type ).to equal :filename }
      end

      context 'single word with end / is a :dir' do
        let(:tokenizer) { Tokenizer.new "foo/" }
        it { expect( tokenizer.tokens.first.type ).to equal :dir }
      end

    end

  end
end
