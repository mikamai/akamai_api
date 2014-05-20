Then /^the output should contain (\d+) times:$/ do |times, content|
  expect(all_output.scan(content).count).to eq times.to_i
end
