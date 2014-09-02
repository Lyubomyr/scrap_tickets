set :stage, :production

role :app, "104.131.26.124"
role :web, "104.131.26.124"
role :db, "104.131.26.124", :primary => true

set :ssh_options, {:user => 'root', :port => 22}
set :deploy_to, "/home/rails"
set :unicorn_conf, "/home/unicorn/unicorn.conf"
set :unicorn_pid, "/home/unicorn/pids/unicorn.pid"
set :rails_env, 'production'

set :branch,  ENV['branch'] || "master"

# set :rvm_type, :user
set :rvm_ruby_string, 'ruby-2.1.2@ff'
set :rvm_ruby_version, '2.1.2p95'

set :monit_restart, false
