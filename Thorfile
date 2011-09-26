# enconding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'bundler/setup'
Bundler.require :default
require 'thor/rake_compat'

class Default < Thor
  include Thor::RakeCompat

  desc "spec", "Run RSpec code examples"
  def spec
    exec "rspec -cfs spec"
  end
end