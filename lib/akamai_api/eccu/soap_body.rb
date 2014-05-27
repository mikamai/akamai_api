require "builder"

module AkamaiApi::Eccu
  # Utility class used by the ECCU request classes to fill the request payload with the arguments
  # requested by a SOAP method.
  #
  # @note Theoretically this class shouldn't exist because Savon should be able to understand
  #   the provided wsdl correctly and the request payload should be filled using its helpers.
  #   In practice, at least with Savon v2.2, it wasn't able to do it, and this class tries to
  #   simplify the creation of the xml payload that encapsulate method arguments.
  #
  # The payload of each request is an xml describing the arguments of the method. E.g.
  #   <filename xsi:type="xsd:string">./publish.xml</filename>
  #   <contents xsi:type="xsd:base64Binary">aGVsbG8gd29ybGQ=</contents>
  #   <notes xsi:type="xsd:string">ECCU Request using AkamaiApi</notes>
  #   <versionString xsi:type="xsd:string"></versionString>
  #   <propertyName xsi:type="xsd:string">foo.com</propertyName>
  #   <propertyType xsi:type="xsd:string">hostheader</propertyType>
  #   <propertyNameExactMatch xsi:type="xsd:boolean">true</propertyNameExactMatch>
  #
  # Using this class you can create the above payload with the following code:
  #
  #   block = SoapBody.new
  #   block.string  :filename,           './publish.xml'
  #   block.text    :contents,           'hello world'
  #   block.string  :notes,              'ECCU request using AkamaiApi'
  #   block.string  :versionString,      ''
  #   block.string  :propertyName,       'foo.com'
  #   block.string  :propertyType,       'hostheader'
  #   block.boolean :propertyExactMatch, true
  #   block.to_s
  class SoapBody
    TAG_TYPES = {
      :boolean => 'xsd:boolean',
      :integer => 'xsd:int',
      :string  => 'xsd:string'
    }
    private_constant :TAG_TYPES

    attr_reader :builder
    private :builder

    def initialize
      @builder = Builder::XmlMarkup.new
    end

    # Appends an argument of type text, encoding the given value in base64
    # @param [String] name argument name
    # @param [String] value
    # @return [SoapBody]
    def text name, value
      builder.tag! name, Base64.encode64(value), 'xsi:type' => 'xsd:base64Binary'
      self
    end

    # @!method boolean(name, value)
    #   Appends an argument of type boolean
    #   @param [String] name argument name
    #   @param [true,false] value
    #   @return [SoapBody]
    # @!method integer(name, value)
    #   Appends an argument of type integer
    #   @param [String] name argument name
    #   @param [Fixnum] value
    #   @return [SoapBody]
    # @!method string(name, value)
    #   Appends an argument of type string
    #   @param [String] name argument name
    #   @param [String] value
    #   @return [SoapBody]
    TAG_TYPES.each do |type, type_code|
      define_method type do |name, value|
        builder.tag! name, value, 'xsi:type' => type_code
        self
      end
    end

    # Appends an argument of type array
    # @param [String] name argument name
    # @param [Array] values
    # @return [SoapBody]
    def array name, values
      array_attrs = {
        'soapenc:arrayType' => "xsd:string[#{values.length}]",
        'xsi:type'          => 'wsdl:ArrayOfString'
      }
      builder.tag! name, array_attrs do |tag|
        values.each { |value| tag.item value }
      end
      self
    end

    # Returns the XML to use to set SOAP method arguments
    # @return [String] the XML to use to set SOAP method arguments
    def to_s
      builder.target!
    end
  end
end
