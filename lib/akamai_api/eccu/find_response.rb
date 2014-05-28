require 'base64'

module AkamaiApi::ECCU
  # {FindResponse} exposes the response received when requesting the details of an Akamai ECCU request
  class FindResponse
    # Raw response object
    # @return [Hash] raw response object
    attr_reader :raw

    # @param [Hash] raw raw response object
    def initialize raw
      @raw = raw
    end

    # Request code
    # @return [Fixnum] request code
    def code
      raw[:file_id]
    end

    # @!method notes
    #   Notes of the request
    #   @return [String] notes of the request
    # @!method email
    #   Email to be notified when the request becomes completed
    #   @return [String] email to be notified when the request becomes completed
    # @!method updated_at
    #   Last time the request was updated
    #   @return [String] last time the request was updated
    # @!method uploaded_by
    #   User that submitted the request
    #   @return [String] user name
    # @!method uploaded_at
    #   Time the request was uploaded
    #   @return [String] time the request was uploaded
    # @!method version
    #   version of the request
    #   @return [String] version of the request
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

    alias_method :status_change_email, :email
    alias_method :update_date,         :updated_at
    alias_method :upload_date,         :uploaded_at
    alias_method :version_string,      :version

    # Uploaded file details
    # @return [Hash] file details
    #   - :content [String] file content
    #   - :size [Fixnum] file size
    #   - :name [String] file name
    #   - :md5 [String] MD5 digest of the file content
    def file
      content64 = get_if_string(raw[:contents])
      {
        :content => content64 ? Base64.decode64(content64) : nil,
        :size    => raw[:file_size].to_i,
        :name    => get_if_string(raw[:filename]),
        :md5     => get_if_string(raw[:md5_digest])
      }.reject { |k, v| v.nil? }
    end

    # Request status
    # @return [Hash] request status
    #   - :extended [String] extended status message
    #   - :code [Fixnum] status code
    #   - :message [String] status message
    #   - :updated_at [String] last time the status has been updated
    def status
      {
        :extended   => get_if_string(raw[:extended_status_message]),
        :code       => raw[:status_code].to_i,
        :message    => get_if_string(raw[:status_message]),
        :updated_at => get_if_string(raw[:status_update_date])
      }.reject { |k, v| v.nil? }
    end

    # Digital property details
    # @return [Hash] property details
    #   - :name [String]
    #   - :exact_match [true,false]
    #   - :type [String]
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
