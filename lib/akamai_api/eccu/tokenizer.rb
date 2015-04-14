require 'akamai_api/eccu/tokenizer_block'

module AkamaiApi::ECCU
  # Class used to tokenize path used for invalidate cache
  #
  # foo/bar/*.txt
  class Tokenizer

    attr_accessor :path, :splitted_path

    SEPARATOR = '/'

    def initialize p
      @path = p
      @splitted_path = []
    end

    def extension_present?
      if ! @path.include? "."
        false
      else
        @path.rindex('.') > @path.rindex('/')
      end
    end

    def split_path
      @path.split(SEPARATOR).each do |block|
        @splitted_path << TokenizerBlock.new(block)
      end

      return @splitted_path
    end

  end

end
