require 'akamai_api/eccu/tokenizer'

module AkamaiApi
  # The {ECCUParser} class is used to create a XML request file starting from a url
  #
  # @example
  #   AkamaiApi::ECCUParser.new(foo/bar/*.png).xml
  class ECCUParser

    PLACEHOLDER = "{YIELD}"
    NOT_ALLOWED_EXTENSIONS = %w[*]
    NOT_ALLOWED_DIRS = %w[. ..]

    attr_reader :tokenizer, :xml, :revalidate_on

    def initialize expression, revalidate_on = 'now'
      raise "Expression can't be empty" if expression.empty?
      revalidate_on = revalidate_on.to_i if revalidate_on != 'now'
      @tokenizer = ECCU::Tokenizer.new expression
      @revalidate_on = revalidate_on
      @xml = "<?xml version=\"1.0\"?><eccu>#{PLACEHOLDER}</eccu>"
      parse
    end

  private

    def parse
      while tokenizer.look_next_token
        tokenizer.next_token
        send "add_#{tokenizer.current_token.type.to_s}_tag", tokenizer.current_token.value
      end

      add_revalidate
    end

    def next_wildcard_extension?
      tokenizer.look_next_token.type == :wildcard and 
        ! tokenizer.look_next_token(2).nil? and 
        tokenizer.look_next_token(2).type == :extension
    end

    def next_filename?
      tokenizer.look_next_token.type == :filename
    end

    def add_revalidate
      xml.gsub! PLACEHOLDER, "<revalidate>#{revalidate_on}</revalidate>"
    end

    def add_dir_tag dir_name
      raise "Dir '#{dir_name}' not allowed" if NOT_ALLOWED_DIRS.include? dir_name

      xml.gsub! PLACEHOLDER, "<match:recursive-dirs value=\"#{dir_name}\">#{PLACEHOLDER}</match:recursive-dirs>"
    end

    def add_this_dir_tag
      xml.gsub! PLACEHOLDER, "<match:this-dir value=\"This Directory Only\">#{PLACEHOLDER}</match:this-dir>"
    end


    def add_extension_tag extension
      raise "Extension '#{extension}' not allowed" if NOT_ALLOWED_EXTENSIONS.include? extension
      raise "Extension will be the last element" if tokenizer.look_next_token != nil

      xml.gsub! PLACEHOLDER, "<match:ext value=\"#{extension}\">#{PLACEHOLDER}</match:ext>"
    end

    def add_filename_tag filename
      xml.gsub! PLACEHOLDER, "<match:filename value=\"#{filename}\" nocase=\"off\">#{PLACEHOLDER}</match:filename>"
    end

    def add_separator_tag separator
      if tokenizer.look_prev_token.type == :dir
        if tokenizer.look_next_token == nil
          add_this_dir_tag
        elsif next_wildcard_extension? or next_filename?
          add_this_dir_tag
        end
      end
    end

    def add_double_wildcard_tag token
      # Double wildcard do nothing
    end

    def add_wildcard_tag wildcard
      if tokenizer.look_next_token.nil? or 
          tokenizer.look_next_token.type == :separator
        xml.gsub! PLACEHOLDER, "<match:sub-dirs-only value=\"Sub-directories Only\">#{PLACEHOLDER}</match:sub-dirs-only>"
      end
    end

  end
end
