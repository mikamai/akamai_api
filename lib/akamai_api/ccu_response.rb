module AkamaiApi
  class CcuResponse
    attr_reader :status_code, :raw

    def initialize(response, requested_items)
      @raw = response
      @requested_items = requested_items
    end

    def raw_body
      @raw.body
    end

    def code
      raw_body[:purge_request_response][:return][:result_code].to_i
    end

    def status
      case code
      when (100..199) then 'Successful Request'
      when (200..299) then 'Warning. The removal request has been accepted'
      when 301 then 'Invalid username or password'
      when 302 then 'Bad syntax for an option'
      when 303 then 'Invalid value for an option'
      when 304 then 'Option already provided'
      when 320 then 'URI provided'
      when 321 then 'Format of ARL/URL is invalid'
      when 322 then 'You are not authorized to purge this ARL/URL'
      when 323 then 'ARL/URL illegal'
      when 332 then 'Maximum number of ARL/URLs in outstanding purge requests exceeded'
      when (300..399) then 'Bad or invalid request'
      when (400..499) then 'Contact Akamai Customer Care'
      end
    end

    def message
      raw_body[:purge_request_response][:return][:result_msg]
    end

    def session_id
      raw_body[:purge_request_response][:return][:session_id]
    end

    def estimated_time
      raw_body[:purge_request_response][:return][:est_time].to_i
    end

    def uri_index
      raw_body[:purge_request_response][:return][:uri_index].to_i
    end

    def uri
      uri_index >= 0 && @requested_items[uri_index] || nil
    end
  end
end