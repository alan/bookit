require File.expand_path(File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'environment'))
Bundler.require_env

ENV["APP_ENV"] = "test"

require 'spec'
require File.dirname(__FILE__) + '/../tennis-slots'

Spec::Runner.configure do |config|
  config.before(:each) { AutomateAT.engine.delete_all }
end