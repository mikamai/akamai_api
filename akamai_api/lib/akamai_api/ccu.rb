require 'active_support/core_ext'

module AkamaiApi
  class Ccu
    extend Savon::Model

    document 'https://ccuapi.akamai.com/ccuapi-axis.wsdl'

    class << self
      def invalidate_cp_code items, args = {}
        invalidate :cpcode, items, args
      end
      def invalidate_url items, args = {}
        invalidate :arl, items, args
      end
      def invalidate items, args = {}
        purge :invalidate, items, args
      end

      def remove_cp_code items, args = {}
        remove :cpcode, items, args
      end
      def remove_url items, args = {}
        remove :arl, items, args
      end
      def remove type, items, args = {}
        purge :remove, type, items, args
      end

      def purge action, type, items, args = {}
        unless %w(invalidate remove).include? action.to_s
          raise "Unknown type '#{action}' (only 'remove' and 'invalidate' are allowed)"
        end
        unless %w(cpcode arl).include? type.to_s
          raise "Unknown type '#{type}' (only 'cpcode' and 'arl' are allowed)"
        end
        options = [ "action=#{action}", "type=#{type}" ]
        if args[:domain]
          unless [:production, :staging].include? args[:domain].to_sym
            raise "Unknown domain type '#{args[:domain]}' (only :production and :staging are allowed)"
          end
          options << "domain=#{args[:domain]}"
        end
        if args[:email] && args[:email].present?
          emails = Array.wrap(args[:email]).join ','
          options << "email-notification=#{emails}"
        end
        response = client.request 'wsdl:purgeRequest' do
          SoapBody.new(soap) do
            string :name, AkamaiApi.config[:auth].first
            string :pwd,  AkamaiApi.config[:auth].last
            string :network, ''
            array  :opt,  options
            array  :uri,  items
          end
        end
        CcuResponse.new response
      end
    end
  end
end