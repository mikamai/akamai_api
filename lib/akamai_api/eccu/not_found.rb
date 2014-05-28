module AkamaiApi::ECCU
  # A simple subclass of StandardError indicating that the requested ECCU resource cannot be found
  class NotFound < StandardError; end
end
