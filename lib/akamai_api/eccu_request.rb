module AkamaiApi
  class EccuRequest
    attr_accessor :file, :status, :code, :notes, :property, :email, :upload_date, :uploaded_by, :version_string

    def initialize attributes = {}
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    def update_notes! notes
      code = self.code.to_i
      body = SoapBody.new do
        integer :fileId, code
        string  :notes,  notes
      end
      resp = client.call :set_notes, :message => body.to_s
      self.notes = notes
      resp.body[:set_notes_response][:success]
    rescue Savon::HTTPError => e
      raise ::AkamaiApi::Unauthorized if e.http.code == 401
      raise
    end

    def update_email! email
      code = self.code.to_i
      body = SoapBody.new do
        integer :fileId, code
        string  :statusChangeEmail, email
      end
      response = client.call :set_status_change_email, :message => body.to_s
      successful = response.body[:set_status_change_email_response][:success]
      self.email = email if successful
      successful
    rescue Savon::HTTPError => e
      raise ::AkamaiApi::Unauthorized if e.http.code == 401
      raise
    end

    def destroy
      code = self.code.to_i
      body = SoapBody.new do
        integer :fileId, code
      end
      response = client.call :delete, :message => body.to_s
      response.body[:delete_response][:success]
    rescue Savon::HTTPError => e
      raise ::AkamaiApi::Unauthorized if e.http.code == 401
      raise
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

      def find code, args = {}
        body = SoapBody.new do
          integer :fileId, code.to_i
          boolean :retrieveContents, args[:verbose] == true
        end
        response = client.call(:get_info, :message => body.to_s)
        response_body = response.body[:get_info_response][:eccu_info]
        EccuRequest.new({
          :file => {
            :content    => Base64.decode64(get_if_kind(response_body[:contents], String) || ''),
            :file_size  => response_body[:file_size].to_i,
            :file_name  => get_if_kind(response_body[:filename], String),
            :md5_digest => get_if_kind(response_body[:md5_digest], String)
          },
          :status => {
            :extended    => get_if_kind(response_body[:extended_status_message], String),
            :code        => response_body[:status_code].to_i,
            :message     => get_if_kind(response_body[:status_message], String),
            :update_date => get_if_kind(response_body[:status_update_date], String)
          },
          :code  => response_body[:file_id],
          :notes => get_if_kind(response_body[:notes], String),
          :property => {
            :name => get_if_kind(response_body[:property_name], String),
            :exact_match => (response_body[:property_name_exact_match] == true),
            :type => get_if_kind(response_body[:property_type], String)
          },
          :email => get_if_kind(response_body[:status_change_email], String),
          :upload_date => get_if_kind(response_body[:upload_date], String),
          :uploaded_by => get_if_kind(response_body[:uploaded_by], String),
          :version_string => get_if_kind(response_body[:version_string], String)
        })
      rescue Savon::HTTPError => e
        raise ::AkamaiApi::Unauthorized if e.http.code == 401
        raise
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
          string :filename,                args[:file_name] || ''
          text   :contents,                content
          string :notes,                   args[:notes] || 'ECCU Request using AkamaiApi gem'
          string :versionString,           args[:version] || ''
          if args[:emails]
            string :statusChangeEmail,     Array.wrap(args[:emails]).join(' ')
          end
          string :propertyName,            property
          string :propertyType,            args[:property_type] || 'hostheader'
          boolean :propertyNameExactMatch, args[:property_exact_match].nil? && true || args[:property_exact_match]
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
