require File.expand_path(File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'environment'))
Bundler.require_env

ENV["APP_ENV"] = "test"

require 'spec'
require File.dirname(__FILE__) + '/../bookit'

Spec::Runner.configure do |config|
  config.before(:each) { AutomateAT::Bookit.engine.delete_all }
end