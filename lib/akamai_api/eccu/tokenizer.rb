require 'ostruct'

module AkamaiApi::ECCU
  # Class used to tokenize path used for invalidate cache
  #
  # foo/bar/*.txt
  class Tokenizer

    attr_accessor :path, :splitted_path, :blocks

    SEPARATOR = '/'
    # When the extension is present i use the ext_separator
    # to obtain the sub block
    #
    # ex: *.png => [*, png]
    EXT_SEPARATOR = '.'

    SPECIAL_TYPES = {
      '*'        => :wildcard,
      '**'       => :double_wildcard,
    }
    ALLOWED_TYPES = [:dir, :extension, :filename, :wildcard, :double_wildcard]
    DEFAULT_TYPE = :dir

    def initialize p
      @path = p
      split_path
    end

    def extension_present?
      if ! @path.include? EXT_SEPARATOR
        false
      else
        @path.rindex( EXT_SEPARATOR ) > @path.rindex( SEPARATOR )
      end
    end

    # if the last char in @path is the SEPARATOR indicate a dir
    # otherwise a filename
    def filename_present?
      ! ( @path[-1,1] == SEPARATOR )
    end

    def split_path
      @blocks = []
      @splitted_path = @path.split(SEPARATOR)
      @splitted_path.each_with_index do |block, index|
        @blocks += create_blocks( block, (index == @splitted_path.size - 1) )
      end

      return @blocks
    end

    # create the object for a single block element
    def single_block b, block_type = nil
      block = OpenStruct.new
      block.vallue = b
      block.type = block_type || check_block_type( b )
      block
    end

    # Create an array of blocks based on block string.
    # Usually create an array with 1 element, but when the block is the last
    # can return an array with multiple elements
    #
    # @param [String] block part of a path string (es. path: "foo/bar/*.png" blocks: [ foo, bar, *.png ])
    # @param [Bool] last_block
    #
    # @return [Array] Array of blocks object
    def create_blocks block, last_block = false
      return [ single_block(block) ] if ! last_block
      # last block
      # extension before filename, becuse is more generic es. *.png
      return extension_blocks( block ) if extension_present?
      return [ single_block( block, ( filename_present? ? :filename : nil ) ) ]
    end

    # Create the array for the extension block
    #
    # @param [String] block es. *.png
    #
    # @return [Array] Array of blocks object
    def extension_blocks block
      extension_blocks = []
      splitted_block = block.split(EXT_SEPARATOR)
      splitted_block.each_with_index do |b, index|
        t = splitted_block.size - 1 == index ? :extension : nil
        extension_blocks << single_block(b, t)
      end

      if ! ( extension_blocks.map(&:type) & SPECIAL_TYPES.values ).empty?
        return extension_blocks
      else
        return [ single_block(block, :filename) ]
      end
    end

    def check_block_type block
      SPECIAL_TYPES.each do |v, t|
        return t if v == block
      end

      DEFAULT_TYPE
    end

  end

end
