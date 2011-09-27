module AkamaiApi
  class LoginInfo
    attr_accessor :username, :password

    def initialize username, password
      self.username = username
      self.password = password
    end

    def == a
      if a.kind_of? AkamaiApi::LoginInfo
        self.username == a.username && self.password == a.password
      else
        false
      end
    end
  end
end
