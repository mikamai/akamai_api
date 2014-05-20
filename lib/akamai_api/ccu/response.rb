require 'spec_helper'

module AkamaiApi::Ccu
  class Response
    attr_reader :raw

    def initialize raw
      @raw = raw
    end

    def support_id
      raw['supportId']
    end

    def code
      raw['httpStatus']
    end
    alias :http_status :code
  end
end
