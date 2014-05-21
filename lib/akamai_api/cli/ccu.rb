%w(cp_code arl status_renderer purge_renderer base).each do |file|
  require File.expand_path "../ccu/#{file}", __FILE__
end

module AkamaiApi::Cli::Ccu
end
