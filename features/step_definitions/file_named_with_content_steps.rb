Given /^a file named "([^"]*)" with the content of "([^"]*)"$/ do |dest_file_name, source_file_name|
  write_file(dest_file_name, File.read(source_file_name))
end
