ENV["APP_ENV"] = "test"

require './config/boot'
Bundler.require("test")


Spec::Runner.configure do |config|
  config.before(:all) { FileUtils.mkdir_p(File.join(ROOT, 'log')) }
  config.before(:each) { AutomateAT::Bookit.engine.delete_all }
end
