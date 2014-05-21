require 'thor'

%w(command ccu eccu app).each do |file|
  require File.expand_path "../cli/#{file}", __FILE__
end

module AkamaiApi::Cli
end
