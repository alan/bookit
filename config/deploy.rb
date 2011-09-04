config = YAML.load_file("#{ENV['HOME']}/.capistrano.yml")['bookit']

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2@bookit'        # Or whatever env you want it to run in.
set :rvm_type, :system

set :application, "bookit"
set :repository,  "git://github.com/alan/bookit.git"

role :web, config['server']
role :app, config['server']

set :port, config['port']

set :scm, :git
set :deploy_via,        :remote_cache
set :repository_cache,  "#{application}_cache"
set :branch,            "master"
set :deploy_to,         "/#{config['dir']}/#{application}"

default_run_options[:pty] = true

set :password,          config['password']
set :user,              config['user']
set :runner,            config['runner']

set :deploy_via, :remote_cache

after 'deploy:symlink', 'deploy:symlink_config'
before 'deploy:restart', 'deploy:fresh_bundle'
after 'deploy:fresh_bundle', 'deploy:reload_bluepill'

namespace :deploy do
  task :symlink_config do
    run "cd #{release_path}/config; ln -nfs #{shared_path}/config/config.yml"
  end

  task :reload_bluepill do
    sudo "bluepill load #{current_path}/config/bookit.pill"
  end

  task :fresh_bundle do
    run "cd #{current_path}; #{sudo} bundle install"
  end

  task :start do
    sudo 'bluepill bookit start'
  end

  task :stop do
    sudo 'bluepill bookit stop'
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo 'bluepill bookit restart'
  end
end

namespace :util do
  task :install_libraries do
    sudo 'apt-get install libxslt-dev'
  end
end

after 'deploy:setup', 'util:install_libraries'
