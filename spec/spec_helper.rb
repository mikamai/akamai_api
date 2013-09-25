require File.expand_path '../../lib/akamai_api', __FILE__
require File.expand_path '../auth.rb', __FILE__

require 'savon/mock/spec_helper'

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