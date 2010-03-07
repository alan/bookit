require 'bookit'
require 'rake'

require 'spec/rake/spectask'
require 'redis/raketasks'

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