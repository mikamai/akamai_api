# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'akamai_api/version'

Gem::Specification.new do |gem|
  gem.name          = "akamai_api"
  gem.version       = AkamaiApi::VERSION
  gem.authors       = ["Nicola Racco"]
  gem.email         = ["nicola@nicolaracco.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'active_support', '>= 2'
  gem.add_dependency 'thor',  '~> 0.16.0'
  gem.add_dependency 'savon', '~> 1.2.0'

  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'savon_spec', '~> 1.3'
end
