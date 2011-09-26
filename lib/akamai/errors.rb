module Akamai
  class Error < RuntimeError
  end

  class LoginError < Error
    def initialize
      super 'Login Error'
    end
  end
end
