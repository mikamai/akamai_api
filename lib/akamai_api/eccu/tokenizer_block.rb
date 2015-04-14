module AkamaiApi::ECCU

  class TokenizerBlock

    attr_accessor :block

    TYPES = {
      wildcard: '*',
      double_wildcard: '**'
    }

    def initialize b
      block = b
    end

    def type
      TYPES.each do |t, value|
        return t if value == @block
      end

      return :dir
    end

  end

end
