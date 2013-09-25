module AkamaiApi
  class SoapBody
    attr_reader :builder

    def initialize &block
      @builder = Builder::XmlMarkup.new
      instance_eval &block if block
    end

    def text name, value
      builder.tag! name, Base64.encode64(value), 'xsi:type' => 'xsd:base64Binary'
    end

    def boolean name, value
      builder.tag! name, value, 'xsi:type' => 'xsd:boolean'
    end

    def integer name, value
      builder.tag! name, value, 'xsi:type' => 'xsd:int'
    end

    def string name, value
      builder.tag! name, value, 'xsi:type' => 'xsd:string'
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
      builder.to_s
    end
  end
end