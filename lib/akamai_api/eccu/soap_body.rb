require "builder"

module AkamaiApi::Eccu
  class SoapBody
    TAG_TYPES = {
      :boolean => 'xsd:boolean',
      :integer => 'xsd:int',
      :string  => 'xsd:string'
    }

    attr_reader :builder

    def initialize &block
      @builder = Builder::XmlMarkup.new
      instance_eval &block if block
    end

    def text name, value
      builder.tag! name, Base64.encode64(value), 'xsi:type' => 'xsd:base64Binary'
    end

    TAG_TYPES.each do |type, type_code|
      define_method type do |name, value|
        builder.tag! name, value, 'xsi:type' => type_code
      end
    end

    def array name, values
      array_attrs = {
        'soapenc:arrayType' => "xsd:string[#{values.length}]",
        'xsi:type'          => 'wsdl:ArrayOfString'
      }
      builder.tag! name, array_attrs do |tag|
        values.each { |value| tag.item value }
      end
    end

    def to_s
      builder.target!
    end
  end
end
