%w(template command ccu_cp_code ccu_arl ccu eccu app).each do |file|
  require File.expand_path "../cli/#{file}", __FILE__
end