require 'active_support/core_ext'

module AkamaiApi
  class Ccu
    extend Savon::Model

    document 'https://ccuapi.akamai.com/ccuapi-axis.wsdl'

    class << self
      [:invalidate, :remove].each do |action|
        send :define_method, action do |type, items, args = {}|
          purge action, type, items, args
        end
        [:arl, :cpcode].each do |type|
          method_name = "#{action}_#{type}".to_sym
          send :define_method, method_name do |items, args = {}|
            purge action, type, items, args
          end
        end
      end

      def purge action, type, items, args = {}
        validate_action action
        validate_type type
        options = ["action=#{action}", "type=#{type}"]
        add_domain args[:domain], options
        add_email args[:email], options
        response = client.request 'wsdl:purgeRequest' do
          SoapBody.new(soap) do
            string :name,    AkamaiApi.config[:auth].first
            string :pwd,     AkamaiApi.config[:auth].last
            string :network, ''
            array  :opt,     options
            array  :uri,     items
          end
        end
        CcuResponse.new response, items
      end

      private

      def validate_action action
        unless %w[invalidate remove].include? action.to_s
          raise "Unknown type '#{action}' (only 'remove' and 'invalidate' are allowed)"
        end
      end

      def validate_type type
        unless %w[cpcode arl].include? type.to_s
          raise "Unknown type '#{type}' (only 'cpcode' and 'arl' are allowed)"
        end
      end

      def add_domain domain, options
        if domain.present?
          unless %w[production staging].include? domain.to_s
            raise "Unknown domain type '#{domain}' (only :production and :staging are allowed)"
          end
          options << "domain=#{domain}"
        end
      end

      def add_email email, options
        if email.present?
          emails = Array.wrap(email).join ','
          options << "email-notification=#{emails}"
        end
      end
    end
  end
end
