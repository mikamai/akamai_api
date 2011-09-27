require 'savon'
require 'active_support/core_ext/module/attribute_accessors'

module AkamaiApi
  mattr_accessor :account
  mattr_accessor :wsdl_folder
  @@wsdl_folder = File.join File.dirname(__FILE__), '../../wsdls'
  
  module WebService
    def self.included klass
      klass.extend ClassMethods
      klass.send :define_method, 'initialize' do |*args|
        if args.length == 0
          @account = AkamaiApi.account
        elsif args.length == 1
          if args[0].kind_of? AkamaiApi::LoginInfo
            @account = args[0]
          else
            raise ArgumentError.new 'Bad argument: expected AkamaiApi::Login if there is only one argument'
          end
        elsif args.length == 2
          @account = AkamaiApi::LoginInfo.new args[0], args[1]
        else
          raise ArgumentError.new 'Too much arguments'
        end
        @client = Savon::Client.new do |wsdl, http|
          wsdl.document = File.join self.class.get_manifest_path
          http.auth.basic @account.username, @account.password if @account
        end
      end
    end

    module ClassMethods
      def get_manifest_path
        File.join AkamaiApi.wsdl_folder, @@manifest
      end

      def service_call sym, &block
        send :define_method, sym.to_s do |*args|
          begin
            instance_exec *args, &block
          rescue Savon::HTTP::Error => e
            raise LoginError.new if e.to_hash[:code] == 401
          end
        end
      end

      def use_manifest manifest
        @@manifest = manifest
      end
    end

    protected
    def client
      @client
    end
    def account
      @account
    end
  end
end
