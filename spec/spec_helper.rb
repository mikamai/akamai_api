require File.expand_path '../../lib/akamai_api', __FILE__
require File.expand_path '../../lib/akamai_api/cli', __FILE__

begin
  require File.expand_path '../auth.rb', __FILE__
rescue LoadError
  AkamaiApi.config[:auth] = ['test_username', 'test_password']
end
require 'savon/mock/spec_helper'
require 'webmock/rspec'
require 'vcr'
require 'coveralls'
Coveralls.wear_merged!

VCR.configure do |c|
  c.cassette_library_dir = 'cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }
  c.configure_rspec_metadata!
  c.after_http_request do |request|
    request.uri.gsub! AkamaiApi.config[:auth].first, 'USERNAME'
    request.uri.gsub! AkamaiApi.config[:auth].last, 'PASSWORD'
  end
  c.before_playback do |i|
    i.request.uri.gsub! 'USERNAME', AkamaiApi.config[:auth].first
    i.request.uri.gsub! 'PASSWORD', AkamaiApi.config[:auth].last
  end
end

# Savon::Spec::Fixture.path = File.expand_path '../fixtures', __FILE__
Dir[File.expand_path '../support/**/*.rb', __FILE__].each do |f|
  require f
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
