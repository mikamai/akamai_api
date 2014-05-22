require 'active_support'
require 'active_support/core_ext/module'

# This patch is needed for adding an option to not check every time the arguments of a request
module Savon
  class MockExpectation
    def verify_message_with_any!
      verify_message_without_any! unless @expected[:message] == :any
    end

    alias_method_chain :verify_message!, :any
  end
end
