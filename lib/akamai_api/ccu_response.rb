require 'ostruct'
require 'active_support/core_ext/module/delegation'

module AkamaiApi
  class CcuResponse
    attr_reader :raw_body, :requested_items

    def initialize(response, requested_items)
      @raw_body        = response.body
      @requested_items = requested_items
    end

    delegate :result_code, :result_msg, :session_id, :est_time, :uri_index, :to => :body
    alias message result_msg

    def body
      @body ||= OpenStruct.new(raw_body[:purge_request_response][:return])
    end

    def code
      result_code.to_i
    end

    def estimated_time
      est_time.to_i
    end

    def uri
      int_index = uri_index.to_i
      int_index >= 0 && requested_items[int_index] || nil
    end

    def status
      case code
      when (100..199) then 'Successful Request'
      when (200..299) then 'Warning. The removal request has been accepted'
      when 301        then 'Invalid username or password'
      when 302        then 'Bad syntax for an option'
      when 303        then 'Invalid value for an option'
      when 304        then 'Option already provided'
      when 320        then 'URI provided'
      when 321        then 'Format of ARL/URL is invalid'
      when 322        then 'You are not authorized to purge this ARL/URL'
      when 323        then 'ARL/URL illegal'
      when 332        then 'Maximum number of ARL/URLs in outstanding purge requests exceeded'
      when (300..399) then 'Bad or invalid request'
      when (400..499) then 'Contact Akamai Customer Care'
      end
    end
  end
end
