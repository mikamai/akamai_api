%w(template).each do |file|
  require File.expand_path "../cli/#{file}", __FILE__
end
