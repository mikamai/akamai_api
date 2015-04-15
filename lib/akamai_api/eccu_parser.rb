require 'akamai_api/eccu/tokenizer'

module AkamaiApi
  # The {ECCUParser} class is used to create a XML request file starting from a url
  #
  # @example
  #   AkamaiApi::ECCUParser.new(foo/bar/*.png).xml
  class ECCUParser

    PLACEHOLDER = "{YIELD}"
    NOT_ALLOWED_EXTENSIONS = %w[.*]
    NOT_ALLOWED_DIRS = %w[. ..]
    attr_reader :tokenizer, :xml

    def initialize expression
      @tokenizer = ECCU::Tokenizer.new expression
      @revalidate_on = "now"
    end

    def xml
      @xml = "<eccu>#{PLACEHOLDER}</eccu>"
      parse
      @xml
    end

  private

    def parse
      while tokenizer.look_next_token
        tokenizer.next_token
        case tokenizer.current_token.type
        when :dir
          add_recursive_dir_tag tokenizer.current_token.value
        when :extension
          add_extension_tag tokenizer.current_token.value
        when :filename
          add_filename_tag tokenizer.current_token.value
        end
      end

      add_revalidate
    end

    def add_revalidate
      @xml.gsub! PLACEHOLDER, "<revalidate>#{@revalidate_on}</revalidate>"
    end

    def add_recursive_dir_tag dir_name
      raise "Dir '#{dir_name}' not allowed" if NOT_ALLOWED_DIRS.include? dir_name

      @xml.gsub! PLACEHOLDER, "<match:recursive-dirs value=\"#{dir_name}\">#{PLACEHOLDER}</match:recursive-dirs>"
    end

    def add_extension_tag extension
      raise "Extension '#{extension}' not allowed" if NOT_ALLOWED_EXTENSIONS.include? extension

      @xml.gsub! PLACEHOLDER, "<match:ext value=\"#{extension}\">#{PLACEHOLDER}</match:ext>"
    end

  end
end
