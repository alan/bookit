require 'rake'
require 'tennis-slots'
require 'spec/rake/spectask'

begin
  # TODO Need a better way for this
  require File.expand_path(File.join(File.dirname(__FILE__), 'vendor', 'gems', 'gems', 'redis-0.1', 'tasks', 'redis.tasks.rb'))
rescue =>e
  puts "Make sure to run 'gem bundle' to bring in all the redis tasks"
end

if !defined?(Spec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = ['-cfs']
  end
end

desc 'Run the scrapper and email new findings'
task :run do
  AutomateAT::go
end

namespace :gems do
  desc 'Bundle required gems'
  task :bundle do
    system "gem install bundler"
    system "gem bundle"
  end
end
  
task :default => :test
task :test => :spec