require 'akamai_api/eccu/tokenizer_block'

module AkamaiApi::ECCU
  # Class used to tokenize path used for invalidate cache
  #
  # foo/bar/*.txt
  class Tokenizer

    attr_accessor :path, :splitted_path, :blocks

    SEPARATOR = '/'
    # When the extension is present i use the sub_separator
    # to obtain the sub block
    #
    # ex: *.png => [*, png]
    SUB_SEPARATOR = '.'

    def initialize p
      @path = p
      @blocks = []
    end

    def extension_present?
      if ! @path.include? "."
        false
      else
        @path.rindex('.') > @path.rindex('/')
      end
    end

    # Use recursive method with self?
    def split_path
      @splitted_path = @path.split(SEPARATOR)
      @splitted_path.each_with_index do |block, index|
        if index == @splitted_path.size - 1
          block.split(SUB_SEPARATOR).each do |sub_block|
            @blocks << TokenizerBlock.new(sub_block)
          end
        else
          @blocks << TokenizerBlock.new(block)
        end
      end

      return @blocks
    end

  end

end
