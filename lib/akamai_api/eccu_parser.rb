require 'akamai_api/eccu/tokenizer'

module AkamaiApi
  # The {ECCUParser} class is used to create a XML request file starting from a url
  #
  # @example
  #   AkamaiApi::ECCUParser.new(foo/bar/*.png).xml
  class ECCUParser

    PLACEHOLDER = "{YIELD}"
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
        tokenizer.nex_token
        case tokenizer.current_token.type
        when :dir
          add_recursive_dir_tag tokenizer.current_token.value
        end
      end

      add_revalidate
    end

    def add_recursive_dir_tag dir_name
      @xml.gsub! PLACEHOLDER, "<match:recursive-dirs value=\"#{dir_name}\">#{PLACEHOLDER}</match:recursive-dirs>"
    end

    def add_revalidate
      @xml.gsub! PLACEHOLDER, "<revalidate>#{@revalidate_on}</revalidate>"
    end

  end
end
