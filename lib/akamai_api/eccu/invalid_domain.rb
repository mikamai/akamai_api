require "akamai_api/error"

module AkamaiApi::ECCU
  # A simple subclass of {AkamaiApi::Error} representing a domain the user is not allowed to operate on
  class InvalidDomain < AkamaiApi::Error
  end
end
