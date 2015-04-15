module AkamaiApi::ECCU

  class Token
    attr_accessor :type, :value

    def initialize type, value
      @type, @value = type, value
    end
  end
end
