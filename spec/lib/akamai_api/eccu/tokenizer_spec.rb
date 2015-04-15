require 'spec_helper'

module AkamaiApi::ECCU
  describe Tokenizer do


    describe '.filename_present?' do
      context 'return true' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/file.png" }
        it { expect(eccu_tokenizer.filename_present?).to be(true) }
      end
      context 'return false' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/" }
        it { expect(eccu_tokenizer.filename_present?).to be(false) }
      end
      context 'return true also without extension' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar" }
        it { expect(eccu_tokenizer.filename_present?).to be(true) }
      end
    end

    describe '.extension_present?' do
      context 'return true' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/*.png" }
        it { expect(eccu_tokenizer.extension_present?).to be(true) }
      end
      context 'return false' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar" }
        it { expect(eccu_tokenizer.extension_present?).to be(false) }
      end

      context '. in dir name return false' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar.baz/" }
        it { expect(eccu_tokenizer.extension_present?).to be(false) }
      end

      context 'ignore * as not allowed extension' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar.*" }
        it { expect(eccu_tokenizer.extension_present?).to be(true) }
      end
    end

    describe '.split_path' do
      context 'return 4 blocks' do
        let(:eccu_tokenizer) { Tokenizer.new "foo/bar/*.png" }
        it { expect(eccu_tokenizer.blocks.size).to equal 4 }

        it 'and all blocks have the correct type' do
          expect( eccu_tokenizer.blocks[0].type ).to equal :dir
          expect( eccu_tokenizer.blocks[1].type ).to equal :dir
          expect( eccu_tokenizer.blocks[2].type ).to equal :wildcard
          expect( eccu_tokenizer.blocks[3].type ).to equal :extension
        end
      end
    end

    describe '.check_block_type' do
      subject{ Tokenizer.new "foo/bar/*.png" }
      context 'first block is a :dir type' do
        it { expect( subject.blocks.first.type ).to equal :dir }
      end
      context 'last block is a :extension type' do
        it { expect( subject.blocks.last.type ).to equal :extension }
      end
    end

  end
end
