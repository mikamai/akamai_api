require 'httparty'

require 'active_support'
require 'active_support/core_ext/object/blank'

require 'akamai_api/ccu/purge'
require 'akamai_api/ccu/status'
require 'akamai_api/ccu/purge_status'

module AkamaiApi
  # This module contains the behavior needed to operate with the
  # Akamai Content Control Utility (CCU) interface.
  #
  # Using the Akamai CCU interface you can:
  # - submit a request to clean one or more resources (CPCodes or ARLs)
  # - check the status of a particular request submitted through the Akamai CCU interface
  # - check the status of the Akamai CCU queue
  #
  # For all operations you can directly use the helpers directly defined in this module.
  #
  # For more informations about the Akamai CCU interface, you can read the
  # {https://api.CCU.akamai.com/CCU/v2/docs/index.html Developers Guide provided by Akamai}
  module CCU
    extend self

    # @!method invalidate(type, items, opts={})
    #   Invalidates one or more resources
    #   @param [String,Symbol] type resource type to clean. Allowed values are:
    #     - :cpcode
    #     - :arl
    #     Check {AkamaiApi::CCU::Purge::Request#type} for more details
    #   @param [String,Array] items resource(s) to invalidate
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @!method remove(type, items, opts={})
    #   Remove one or more resources
    #   @param [String,Symbol] type resource type to clean. Allowed values are:
    #     - :cpcode
    #     - :arl
    #     Check {AkamaiApi::CCU::Purge::Request#type} for more details
    #   @param [String,Array] items resource(s) to remove
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @!method invalidate_arl(items, opts={})
    #   Invalidates one or more ARLs
    #   @param [String,Array] items ARL(s) to invalidate
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @!method invalidate_cpcode(items, opts={})
    #   Invalidates one or more CPCodes
    #   @param [String,Array] items CPCode(s) to invalidate
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @!method remove_arl(items, opts={})
    #   Invalidates one or more ARLs
    #   @param [String,Array] items ARL(s) to remove
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @!method remove_cpcode(items, opts={})
    #   Invalidates one or more CPCodes
    #   @param [String,Array] items CPCode(s) to remove
    #   @param [Hash] opts additional options
    #   @option opts [String,Symbol] :domain domain type where to act. Allowed values are:
    #     - :production
    #     - :staging
    #     Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    #   @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    [:invalidate, :remove].each do |action|
      define_method action do |type, items, opts={}|
        purge action, type, items, opts
      end
      [:arl, :cpcode].each do |type|
        define_method "#{action}_#{type}" do |items, opts={}|
          purge action, type, items, opts
        end
      end
    end

    # Purges one or more resources
    # @param [String,Symbol] action type of clean action. Allowed values are:
    #   - :invalidate
    #   - :remove
    #   Check {AkamaiApi::CCU::Purge::Request#action} for more details
    # @param [String,Symbol] type type of resource to clean. Allowed values are:
    #   - :cpcode
    #   - :arl
    #   Check {AkamaiApi::CCU::Purge::Request#type} for more details
    # @param [String, Array] items resource(s) to clean
    # @param [Hash] opts additional options
    # @option opts [String] :domain domain type where to act. Allowed values are:
    #   - :production
    #   - :staging
    #   Check {AkamaiApi::CCU::Purge::Request#domain} for more details
    # @return [AkamaiApi::CCU::Purge::Response] an object representing the received response
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def purge action, type, items, opts = {}
      request = Purge::Request.new action, type, domain: opts[:domain]
      request.execute items
    end

    # @overload status
    #   Checks the status of the Akamai CCU queue
    #   @return [AkamaiApi::CCU::Status::Response] a response object describing the status of the Akamai CCU queue
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @overload status(progress_uri)
    #   Checks the status of an Akamai CCU purge request
    #   @param [String] purge_id_or_progress_uri request id
    #     (both purge_id and progress_uri are accepted)
    #   @return [AkamaiApi::CCU::PurgeStatus::Response] an object detailing the response
    #   @raise [AkamaiApi::CCU::Error] when there is an error in the request
    #   @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # Checks the status of the Akamai CCU queue or the status of a purge request
    def status purge_id_or_progress_uri = nil
      if purge_id_or_progress_uri
        PurgeStatus::Request.new.execute purge_id_or_progress_uri
      else
        Status::Request.new.execute
      end
    end
  end
end
