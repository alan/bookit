ENV["APP_ENV"] = "test"

require 'spec'
require File.dirname(__FILE__) + '/../bookit'
Bundler.require_env("test")

Spec::Runner.configure do |config|
  config.before(:each) { AutomateAT::Bookit.engine.delete_all }
end