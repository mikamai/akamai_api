module Akamai
  @wsdl_folder = File.join File.dirname(__FILE__), '../../wsdls'
  @login = nil

  def self.account
    @account
  end
  def self.account= account
    @account = account
  end
  def self.wsdl_folder
    @wsdl_folder
  end
  def self.wsdl_folder= folder
    @wsdl_folder = folder
  end
  
  module WebService
    def self.included klass
      klass.extend ClassMethods
      klass.send :define_method, 'initialize' do |*args|
        if args.length > 0
          @account = Akamai::LoginInfo.new args[0], args[1]
        else
          @account = Akamai.account
        end
        @client = Savon::Client.new do |wsdl, http|
          wsdl.document = File.join self.class.get_manifest_path
          http.auth.basic @account.username, @account.password if @account
        end
      end
    end

    module ClassMethods
      def get_manifest_path
        File.join Akamai.wsdl_folder, @manifest
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
        @manifest = manifest
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
