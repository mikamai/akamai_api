module Akamai
  class LoginInfo
    attr_accessor :username, :password

    def initialize username, password
      self.username = username
      self.password = password
    end
  end
end
