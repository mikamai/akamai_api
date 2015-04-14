require 'spec_helper'

module AkamaiApi::ECCU
  describe Tokenizer do
    let(:eccu_tokenizer) { Tokenizer.new "foo/bar/*.png" }


    describe '.extension_present?' do
      context 'return true' do
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
      context 'return 3 blocks' do
        it { expect(eccu_tokenizer.split_path.size).to equal 3 }
      end
    end

  end
end
