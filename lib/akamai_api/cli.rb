%w(template command ccu_cp_code ccu_url ccu eccu).each do |file|
  require File.expand_path "../cli/#{file}", __FILE__
end