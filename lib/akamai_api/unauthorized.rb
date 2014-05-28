require "akamai_api/error"

module AkamaiApi
  # A simple subclass of {AkamaiApi::Error} representing the "invalid login credentials" error
  class Unauthorized < AkamaiApi::Error; end
end
