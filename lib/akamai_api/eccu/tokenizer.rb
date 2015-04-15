require 'akamai_api/eccu/token'

module AkamaiApi::ECCU
  # Class used to tokenize path used for invalidate cache
  #
  # foo/bar/*.txt
  class Tokenizer

    SEPARATORS = ['/']
    DIR_REGEXP = /^[^\/]+$/
    WILDCARD_REGEXP = /^\*{1,2}$/

    attr_reader :tokens, :cursor

    def initialize expression
      tokenize expression
      @cursor = -1
    end

    def current_token
      return nil if @cursor == -1
      @tokens[cursor]
    end

    def nex_token
      @cursor += 1
      current_token
    end

    def look_next_token
      @tokens[cursor + 1]
    end

  private 

    def tokenize expression
      @tokens = []
      expression_to_parse = expression.strip
      while expression_to_parse.size > 0
        @tokens << read_next_token(expression_to_parse)
      end
    end

    def read_next_token expression_to_parse
      expression_to_parse.strip!
      next_char = expression_to_parse.slice 0
      if SEPARATORS.include? next_char
        read_next_separator_token expression_to_parse
      elsif next_char =~ WILDCARD_REGEXP
        read_next_wildcard_token expression_to_parse
      elsif next_char =~ DIR_REGEXP
        read_next_dir_token expression_to_parse
      end
    end

    def read_next_separator_token expression_to_parse
      Token.new :separator, expression_to_parse.slice!(0)
    end

    def read_next_wildcard_token expression_to_parse
      Token.new :separator, expression_to_parse.slice!(0)
    end

    def read_next_dir_token expression_to_parse
      dir_value = ''
      next_char = ''
      begin
        dir_value << expression_to_parse.slice!(0)
        next_char = expression_to_parse.slice 0
      end while next_char && "#{dir_value}#{next_char}" =~ DIR_REGEXP

      if SEPARATORS.include? next_char
        Token.new :dir, dir_value
      else
        Token.new :filename, dir_value
      end
    end

  end

end
