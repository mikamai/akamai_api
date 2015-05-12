# encoding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)

require 'bundler'
require 'thor/rake_compat'

class Default < Thor
  include Thor::RakeCompat
  Bundler::GemHelper.install_tasks

  desc "build", "Build akamai_api-#{AkamaiApi::VERSION}.gem into the pkg directory"
  def build
    Rake::Task["build"].execute
  end

  desc "install", "Build and install akamai_api-#{AkamaiApi::VERSION}.gem into system gems"
  def install
    Rake::Task["install"].execute
  end

  desc "release", "Create tag v#{AkamaiApi::VERSION} and build and push akamai_api-#{AkamaiApi::VERSION}.gem to Rubygems"
  def release
    Rake::Task["release"].invoke
  end

  desc "spec", "Run RSpec code examples"
  def spec
    exec "rspec --color --format=documentation spec"
  end

  desc "features", "Run Cucumber features"
  def features
    exec "cucumber"
  end

  desc "coveralls", "Push coveralls stats"
  def coveralls
    require 'coveralls'
    Coveralls.push!
  end
end
