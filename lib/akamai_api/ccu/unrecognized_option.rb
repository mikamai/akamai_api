require "akamai_api/error"

module AkamaiApi::CCU
  # A simple subclass of {AkamaiApi::Error} representing an unrecognized option value provided to the CCU interface
  class UnrecognizedOption < AkamaiApi::Error; end
end
