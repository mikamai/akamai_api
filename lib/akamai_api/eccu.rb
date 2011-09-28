require 'base64'

module AkamaiApi
  class Eccu
    include AkamaiApi::WebService

    use_manifest 'https://control.akamai.com/webservices/services/PublishECCU?wsdl', 'eccu.wsdl'

    service_call :get_ids do
      resp = client.request 'getIds'
      resp.to_hash[:get_ids_response][:file_ids][:file_ids].map do |v|
        v.to_i
      end
    end

    service_call :get_info do |id|
      resp = client.request 'getInfo' do |soap|
        soap.body = {
          :fileId => id,
          :retrieveContents => true
        }
      end
      resp = resp[:get_info_response][:eccu_info]
      {
        :id => resp[:file_id].to_i,
        :content => Base64.decode64(resp[:contents]),
        :notes => get_if(resp[:notes], String),
        :version => get_if(resp[:version_string], String),
        :file => {
          :name => get_if(resp[:filename], String),
          :size => get_if(resp[:file_size], Fixnum),
          :upload_date => resp[:upload_date],
          :md5 => resp[:md5_digest]
        },
        :property => {
          :name => resp[:property_name],
          :exact_match => resp[:property_name_exact_match],
          :type => resp[:property_type]
        },
        :status => {
          :update_date => resp[:status_update_date],
          :code => resp[:status_code].to_i,
          :message => get_if(resp[:status_message], String),
          :extended => get_if(resp[:extended_status_message], String),
          :notify_email => get_if(resp[:status_change_email], String)
        }
      }
    end

    service_call :set_notes do |id, notes|
      resp = client.request 'setNotes' do |soap|
        soap.body = {
          :fileId => id.to_i,
          :notes => notes
        }
      end
      resp.to_hash[:set_notes_response][:success]
    end

    service_call :set_notify_email do |id, email|
      resp = client.request 'setStatusChangeEmail' do |soap|
        soap.body = {
          :fileId => id.to_i,
          :statusChangeEmail => email
        }
      end
      resp.to_hash[:set_status_change_email_response][:success]
    end

    service_call :delete do |id|
      resp = client.request 'delete' do |soap|
        soap.body = {
          :fileId => id.to_i
        }
      end
      resp.to_hash[:delete_response][:success]
    end

    service_call :upload do |content, options|
      resp = client.request 'upload' do |soap|
        soap.body = {
          :filename => options[:name] || '',
          :contents => Base64.encode64(content),
          :notes => options[:notes] || '',
          :versionString => options[:version] || '',
          :statusChangeEmail => options[:notify_email],
          :propertyName => options[:property],
          :propertyType => options[:property_type] || 'hostheader',
          :propertyNameExactMatch => options[:property_exact_match] || true
        }
      end
      resp.to_hash[:upload_response][:fileId]
    end

    private
    def get_if property, kind, default = nil
      property.kind_of?(kind) && property or default
    end
  end
end
