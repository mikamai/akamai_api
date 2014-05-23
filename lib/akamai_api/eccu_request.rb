require "savon"
require "active_support"
require "active_support/core_ext/array"
require "active_support/core_ext/object/blank"

require "akamai_api/eccu/soap_body"
require "akamai_api/eccu/update_notes_request"
require "akamai_api/eccu/update_email_request"
require "akamai_api/eccu/destroy_request"
require "akamai_api/eccu/find_request"

SoapBody = AkamaiApi::Eccu::SoapBody
module AkamaiApi
  class EccuRequest
    attr_accessor :file, :status, :code, :notes, :property, :email, :upload_date, :uploaded_by, :version_string

    def initialize attributes = {}
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    def update_notes! notes
      response = AkamaiApi::Eccu::UpdateNotesRequest.new(code).execute(notes)
      response.tap do |successful|
        self.notes = notes if successful
      end
    end

    def update_email! email
      response = AkamaiApi::Eccu::UpdateEmailRequest.new(code).execute(email)
      response.tap do |successful|
        self.email = email if successful
      end
    end

    def destroy
      AkamaiApi::Eccu::DestroyRequest.new(code).execute
    end

    class << self
      def all_ids
        client.call(:get_ids).body[:get_ids_response][:file_ids][:file_ids]
      rescue Savon::HTTPError => e
        raise ::AkamaiApi::Unauthorized if e.http.code == 401
        raise
      end

      def all args = {}
        Array.wrap(all_ids).map { |v| EccuRequest.find v, args }
      end

      def last args = {}
        find all_ids.last, args
      end

      def first args = {}
        find all_ids.first, args
      end

      def find code, verbose: true
        response = AkamaiApi::Eccu::FindRequest.new(code).execute verbose
        new({
              :file => response.file,
              :status => response.status,
              :code => response.code,
              :notes => response.notes,
              :property => response.property,
              :email => response.email,
              :upload_date => response.uploaded_at,
              :uploaded_by => response.uploaded_by,
              :version_string => response.version
            })
      end

      def publish_file property, file_name, args = {}
        args[:file_name] = file_name
        publish property, File.read(file_name), args
      end

      def publish property, content, args = {}
        body = build_publish_soap_body property, content, args
        resp = client.call :upload, :message_tag => 'upload', :message => body.to_s
        resp.body[:upload_response][:file_id].to_i
      rescue Savon::HTTPError => e
        raise ::AkamaiApi::Unauthorized if e.http.code == 401
        raise
      end

      private

      def build_publish_soap_body property, content, args
        SoapBody.new do
          string :filename,                args.fetch(:file_name, '')
          text   :contents,                content
          string :notes,                   args.fetch(:notes, 'ECCU Request using AkamaiApi gem')
          string :versionString,           args.fetch(:version,  '')
          if args[:emails]
            string :statusChangeEmail,     Array.wrap(args[:emails]).join(' ')
          end
          string :propertyName,            property
          string :propertyType,            args.fetch(:property_type, 'hostheader')
          boolean :propertyNameExactMatch, args.fetch(:property_exact_match,  true)
        end
      end

      # This method is used because, for nil values, savon will respond with an hash containing all other attributes.
      # If we check that the expected type is matched, we can
      # prevent to retrieve wrong values
      def get_if_kind value, kind
        value.kind_of?(kind) && value || nil
      end

      def client
        savon_args = {
          :wsdl       => File.expand_path('../../../wsdls/eccu.wsdl', __FILE__),
          :basic_auth => AkamaiApi.config[:auth],
          :log        => AkamaiApi.config[:log]
        }
        Savon.client savon_args
      end
    end

    private

    def client
      self.class.send(:client)
    end
  end
end
