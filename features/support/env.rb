require 'akamai_api'
require 'akamai_api/cli'
require 'aruba'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'vcr'
require 'webmock'

require File.expand_path '../../../spec/auth', __FILE__
ENV['AKAMAI_USERNAME'], ENV['AKAMAI_PASSWORD'] = AkamaiApi.config[:auth]

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'cassettes'
  c.default_cassette_options = {
    record: :once
  }
  c.after_http_request do |request|
    request.uri.gsub! ENV['AKAMAI_USERNAME'], 'USERNAME'
    request.uri.gsub! ENV['AKAMAI_PASSWORD'], 'PASSWORD'
  end
  c.before_playback do |i|
    i.request.uri.gsub! 'USERNAME', ENV['AKAMAI_USERNAME']
    i.request.uri.gsub! 'PASSWORD', ENV['AKAMAI_PASSWORD']
  end
end

class VcrFriendlyCLI
  def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    $stdin = @stdin
    $stdout = @stdout
    @kernel.exit AkamaiApi::Cli::App.start(@argv.dup)
  end
end

Before do
  @aruba_timeout_seconds = 30
end

Before('@vcr') do
  Aruba::InProcess.main_class = VcrFriendlyCLI
  Aruba.process = Aruba::InProcess
end

After('@vcr') do
  Aruba.process = Aruba::SpawnProcess
  VCR.eject_cassette
  $stdin = STDIN
  $stdout = STDOUT
end
