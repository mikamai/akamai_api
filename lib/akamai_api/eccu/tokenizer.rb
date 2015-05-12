require 'akamai_api/eccu/token'

module AkamaiApi::ECCU
  # Class used to tokenize path used for invalidate cache
  #
  # foo/bar/*.txt
  class Tokenizer

    SEPARATORS = ['/']
    DIR_REGEXP = /^[^\/]+$/
    WILDCARD_REGEXP = /^\**$/

    attr_reader :tokens, :cursor

    def initialize expression
      @cursor = -1
      tokenize expression
    end

    def current_token
      return nil if cursor == -1
      tokens[cursor]
    end

    def next_token
      @cursor += 1
      current_token
    end

    def look_next_token i = 1
      tokens[cursor + i] 
    end

    def look_prev_token i = 1
      tokens[cursor - 1]
    end

    def look_next_token_except exclude_type = nil
      look_next_token if exclude_type == nil

      i = 1
      while tokens[cursor + i].type == exclude_type
        i += 1
      end
      tokens[cursor + i]
    end

    def look_next_token_of_type token_type = nil
      look_next_token if token_type == nil

      i = cursor
      while tokens.size < i
        return tokens[i] if tokens[i].type == token_type
        i += 1
      end
      nil
    end

  private 

    def tokenize expression
      @tokens = []
      expression_to_parse = expression.strip
      while expression_to_parse.size > 0
        tokens << read_next_token(expression_to_parse)
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
      else
        raise "Unknown token starting with '#{next_char}'"
      end
    end

    def read_next_separator_token expression_to_parse
      Token.new :separator, expression_to_parse.slice!(0)
    end

    def read_next_wildcard_token expression_to_parse
      wildcard_value, next_char = loop_until_regexp expression_to_parse, WILDCARD_REGEXP

      if wildcard_value.size == 1
        Token.new :wildcard, wildcard_value
      elsif wildcard_value.size == 2
        Token.new :double_wildcard, wildcard_value
      else
        raise "Unknown wildcard '#{wildcard_value}'"
      end
    end

    def read_next_dir_token expression_to_parse
      dir_value, next_char = loop_until_regexp expression_to_parse, DIR_REGEXP

      if tokens.size > 0 && tokens.last.type == :wildcard
        Token.new :extension, dir_value.gsub('.','')
      elsif SEPARATORS.include? next_char
        Token.new :dir, dir_value
      else
        Token.new :filename, dir_value
      end
    end

    def loop_until_regexp expression_to_parse, regexp
      looped_value = ''
      next_char = ''
      begin
        looped_value << expression_to_parse.slice!(0)
        next_char = expression_to_parse.slice 0
      end while next_char && "#{looped_value}#{next_char}" =~ regexp

      return looped_value, next_char
    end

  end

end
