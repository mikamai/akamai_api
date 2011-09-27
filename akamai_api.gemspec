# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "akamai_api/version"

Gem::Specification.new do |s|
  s.add_dependency 'savon', '>=0.9.7'
  s.add_dependency 'mustache'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'thor'

  s.name        = "akamai_api"
  s.version     = AkamaiApi::VERSION
  s.authors     = ["Nicola Racco"]
  s.email       = ["nicola@nicolaracco.com"]
  s.homepage    = ""
  s.summary     = %q{Proxy classes to Akamai Web Services}
  s.description = %q{Proxy classes to Akamai Web Services}

  s.rubyforge_project = "akamai_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib', 'templates', 'wsdls']
end
