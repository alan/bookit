ENV["APP_ENV"] = "test"

require File.dirname(__FILE__) + '/../config/boot'
Bundler.require("test")

Spec::Runner.configure do |config|
  config.before(:each) { AutomateAT::Bookit.engine.delete_all }
end