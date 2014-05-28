require "savon"
require "active_support"
require "active_support/core_ext/array"
require "active_support/core_ext/object/blank"

require "akamai_api/eccu/soap_body"
require "akamai_api/eccu/update_attribute_request"
require "akamai_api/eccu/destroy_request"
require "akamai_api/eccu/find_request"
require "akamai_api/eccu/publish_request"
require "akamai_api/eccu/list_request"

module AkamaiApi
  class ECCURequest
    attr_accessor :file, :status, :code, :notes, :property, :email, :upload_date, :uploaded_by, :version

    def initialize attributes = {}
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    {
      notes: :notes,
      email: :status_change_email
    }.each do |name, attribute|
      define_method "update_#{name}!" do |value|
        successful = AkamaiApi::ECCU::UpdateAttributeRequest.new(code, attribute).execute(value)
        send "#{name}=", value if successful
        successful
      end
    end

    def destroy
      AkamaiApi::ECCU::DestroyRequest.new(code).execute
    end

    class << self
      def all_ids
        AkamaiApi::ECCU::ListRequest.new.execute
      end

      def all args = {}
        all_ids.map { |v| ECCURequest.find v, args }
      end

      def last args = {}
        find all_ids.last, args
      end

      def first args = {}
        find all_ids.first, args
      end

      def find code, args = {}
        response = AkamaiApi::ECCU::FindRequest.new(code).execute args.fetch(:verbose, true)
        new :file        => response.file,
            :status      => response.status,
            :code        => response.code,
            :notes       => response.notes,
            :property    => response.property,
            :email       => response.email,
            :upload_date => response.uploaded_at,
            :uploaded_by => response.uploaded_by,
            :version     => response.version
      end

      def publish_file property, file_name, args = {}
        args[:file_name] = file_name
        publish property, File.read(file_name), args
      end

      def publish property, content, args = {}
        args = args.dup
        AkamaiApi::ECCU::PublishRequest.new(property, extract_property_arguments(args)).execute content, args
      end

      private

      def extract_property_arguments args
        { type: args.delete(:property_type), exact_match: args.delete(:property_exact_match) }.reject { |k, v| v.nil? }
      end
    end
  end
end
