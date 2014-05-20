module AkamaiApi
  module Cli
    class Eccu < Command
      desc 'requests', 'Print the list of the last requests made to ECCU'
      method_option :content, :type => :boolean, :aliases => '-c',
                    :desc => 'Print request content too'
      def requests
        load_config
        requests = AkamaiApi::EccuRequest.all :verbose => options[:content]
        requests.each do |request|
          puts '------------'
          puts AkamaiApi::Cli::Template.eccu_request request
        end
        puts '------------'
      rescue ::AkamaiApi::Unauthorized
        puts "Your login credentials are invalid."
      end

      desc 'last_request', 'Print the last request made to ECCU'
      method_option :content, :type => :boolean, :aliases => '-c',
                    :desc => 'Print request content too'
      def last_request
        load_config
        request = AkamaiApi::EccuRequest.last :verbose => options[:content]
        puts '------------'
        puts AkamaiApi::Cli::Template.eccu_request request
        puts '------------'
      rescue ::AkamaiApi::Unauthorized
        puts "Your login credentials are invalid."
      end

      desc 'publish_xml path/to/request.xml john.com', 'Publish a request made in XML for the specified Digital Property (usually the Host Header)'
      long_desc 'Publish a request made in XML (ECCU Request Format) and apply it to the specified Digital Property (usually the Host Header)'
      method_option :property_type, :type => :string, :aliases => '-pt',
                    :default => 'hostheader', :banner => 'type',
                    :desc => 'Type of enlisted properties'
      method_option :no_exact_match, :type => :boolean,
                    :desc => 'Do not do an exact match on property names'
      method_option :emails,   :type => :array,  :aliases => '-e',
                    :banner => "foo@foo.com bar@bar.com",
                    :desc => 'Email(s) to use to send notification on status change'
      method_option :notes, :type => :string, :aliases => '-n',
                    :default => 'ECCU Request using AkamaiApi gem'
      def publish_xml(source, property)
        load_config
        args = {
          :notes => options[:notes],
          :property_exact_match => !options[:no_exact_match],
          :property_type => options[:property_type],
          :emails => options[:emails]
        }
        id = AkamaiApi::EccuRequest.publish_file property, source, args
        puts 'Request correctly published. Details:'
        puts '------------'
        puts AkamaiApi::Cli::Template.eccu_request AkamaiApi::EccuRequest.find id, :verbose => true
        puts '------------'
      rescue ::AkamaiApi::Unauthorized
        puts "Your login credentials are invalid."
      rescue Savon::SOAPFault
        puts $!.message
      end
    end
  end
end
