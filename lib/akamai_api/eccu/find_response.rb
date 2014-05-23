require 'base64'

module AkamaiApi::Eccu
  class FindResponse
    attr_reader :raw

    def initialize raw
      @raw = raw
    end

    def code
      raw[:file_id]
    end

    {
      :notes       => :notes,
      :email       => :status_change_email,
      :updated_at  => :update_date,
      :uploaded_at => :upload_date,
      :uploaded_by => :uploaded_by,
      :version     => :version_string
    }.each do |local_field, soap_field|
      define_method local_field do
        get_if_string(raw[soap_field])
      end
    end

    def file
      content64 = get_if_string(raw[:contents])
      {
        :content => content64 ? Base64.decode64(content64) : nil,
        :size    => raw[:file_size].to_i,
        :name    => get_if_string(raw[:filename]),
        :md5     => get_if_string(raw[:md5_digest])
      }.reject { |k, v| v.nil? }
    end

    def status
      {
        :extended   => get_if_string(raw[:extended_status_message]),
        :code       => raw[:status_code].to_i,
        :message    => get_if_string(raw[:status_message]),
        :updated_at => get_if_string(raw[:status_update_date])
      }.reject { |k, v| v.nil? }
    end

    def property
      {
        :name        => get_if_string(raw[:property_name]),
        :exact_match => (raw[:property_name_exact_match] == true),
        :type        => get_if_string(raw[:property_type])
      }.reject { |k, v| v.nil? }
    end

    private

    # This method is used because, for nil values, savon will respond with an hash containing all other attributes.
    # If we check that the expected type is matched, we can
    # prevent to retrieve wrong values
    def get_if_string value
      value.kind_of?(String) && value || nil
    end
  end
end
