only "backend" do
  gem "mechanize"
  gem "redis", "0.1.1", :git => "git://github.com/ezmobius/redis-rb.git"
  gem "pony"
end

only "daemon" do
  gem "daemons", '1.0.11', :git => "git://github.com/ghazel/daemons.git"
  gem "eventmachine"
end

only "test" do
  gem "rspec"
end

source "http://gemcutter.org"
bundle_path "vendor/gems"
bin_path "bin"

disable_rubygems