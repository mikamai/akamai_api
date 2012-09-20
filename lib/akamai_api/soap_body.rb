module AkamaiApi
  class SoapBody
    attr_accessor :soap

    def initialize soap, &block
      self.soap = soap
      self.soap.namespaces['xmlns:soapenc'] = 'http://schemas.xmlsoap.org/soap/encoding/'
      instance_eval &block if block
    end

    def body
      soap.body ||= {}
    end

    def body_attributes
      body[:attributes!] ||= {}
    end

    def text name, value
      name = name.to_sym
      body[name] = Base64.encode64 value
      body_attributes[name] = { 'xsi:type' => 'xsd:base64Binary' }
    end

    def boolean name, value
      name = name.to_sym
      body[name] = value
      body_attributes[name] = { 'xsi:type' => 'xsd:boolean' }
    end

    def integer name, value
      name = name.to_sym
      body[name] = value
      body_attributes[name] = { 'xsi:type' => 'xsd:int' }
    end

    def string name, value
      name = name.to_sym
      body[name] = value
      body_attributes[name] = { 'xsi:type' => 'xsd:string' }
    end

    def array name, values
      name = name.to_sym
      body[name] = { 'item' => values }
      body_attributes[name] = {
        'soapenc:arrayType' => "xsd:string[#{values.length}]",
        'xsi:type'          => 'wsdl:ArrayOfString'
      }
    end
  end
end