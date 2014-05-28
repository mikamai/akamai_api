require "akamai_api/error"

module AkamaiApi::ECCU
  # A simple subclass of {AkamaiApi::Error} indicating that the requested ECCU resource cannot be found
  class NotFound < AkamaiApi::Error; end
end
