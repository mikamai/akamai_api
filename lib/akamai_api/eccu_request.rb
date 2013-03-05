module AkamaiApi
  class EccuRequest
    extend Savon::Model

    document 'https://control.akamai.com/webservices/services/PublishECCU?wsdl'

    attr_accessor :file, :status, :code, :notes, :property, :email, :upload_date, :uploaded_by, :version_string

    def initialize attributes = {}
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end

    def update_notes! notes
      code = self.code.to_i
      resp = client.request 'setNotes' do
        SoapBody.new(soap) do
          integer :fileId, code
          string  :notes,  notes
        end
      end
      self.notes = notes
      resp.body[:set_notes_response][:success]
    end

    def update_email! email
      code = self.code.to_i
      resp = client.request 'setStatusChangeEmail' do
        SoapBody.new(soap) do
          integer :fileId, code
          string  :statusChangeEmail, email
        end
      end
      self.email = email
      resp.body[:set_status_change_email_response][:success]
    end

    def destroy
      code = self.code.to_i
      resp = client.request 'delete' do |soap|
        SoapBody.new(soap) do
          integer :fileId, code
        end
      end
      resp.body[:delete_response][:success]
    end

    class << self
      def all_ids
        basic_auth *AkamaiApi.config[:auth]
        client.request('getIds').body[:get_ids_response][:file_ids][:file_ids]
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
        basic_auth *AkamaiApi.config[:auth]
        resp = client.request 'getInfo' do
          SoapBody.new(soap) do
            integer :fileId, code.to_i
            boolean :retrieveContents, args[:verbose] == true
          end
        end
        resp = resp[:get_info_response][:eccu_info]
        EccuRequest.new({
          :file => {
            :content    => Base64.decode64(get_if_kind(resp[:contents], String) || ''),
            :file_size  => resp[:file_size].to_i,
            :file_name  => get_if_kind(resp[:filename], String),
            :md5_digest => get_if_kind(resp[:md5_digest], String)
          },
          :status => {
            :extended    => get_if_kind(resp[:extended_status_message], String),
            :code        => resp[:status_code].to_i,
            :message     => get_if_kind(resp[:status_message], String),
            :update_date => get_if_kind(resp[:status_update_date], String)
          },
          :code  => resp[:file_id],
          :notes => get_if_kind(resp[:notes], String),
          :property => {
            :name => get_if_kind(resp[:property_name], String),
            :exact_match => (resp[:property_name_exact_match] == true),
            :type => get_if_kind(resp[:property_type], String)
          },
          :email => get_if_kind(resp[:status_change_email], String),
          :upload_date => get_if_kind(resp[:upload_date], String),
          :uploaded_by => get_if_kind(resp[:uploaded_by], String),
          :version_string => get_if_kind(resp[:version_string], String)
        })
      end

      def publish_file property, file_name, args = {}
        args[:file_name] = file_name
        publish property, File.read(file_name), args
      end

      def publish property, content, args = {}
        basic_auth *AkamaiApi.config[:auth]
        resp = client.request 'upload' do
          SoapBody.new(soap) do
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
        resp.body[:upload_response][:file_id].to_i
      end

      private

      # This method is used because, for nil values, savon will respond with an hash containing all other attributes.
      # If we check that the expected type is matched, we can
      # prevent to retrieve wrong values
      def get_if_kind value, kind
        value.kind_of?(kind) && value || nil
      end
    end
  end
end