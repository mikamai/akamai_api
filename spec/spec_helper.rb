require File.expand_path '../../lib/akamai_api', __FILE__
require File.expand_path '../auth.rb', __FILE__

require 'savon_spec'

Savon::Spec::Fixture.path = File.expand_path '../fixtures', __FILE__
Dir[File.expand_path '../support/**/*.rb', __FILE__].each do |f|
  require f
end

RSpec.configure do |config|
  config.include Savon::Spec::Macros
end