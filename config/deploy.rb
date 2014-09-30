# config valid only for Capistrano 3.1
lock '3.2.1'

set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-2.1.2/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-2.1.2/bin:$PATH",
  'RUBY_VERSION' => 'ruby 2.1.2',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-2.1.2',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-2.1.2',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-2.1.2@global/bin/bundle'  # If you are using bundler.
}
set :rvm_ruby_version, 'ruby-2.1.2@letsfly'
set :rvm_type, :system

set :monit_restart, false

set :application, 'findfly'
set :scm, "git"
set :repo_url, 'git@github.com:Lyubomyr/letsfly.git'
set :server, :unicorn

set :ssh_options, {:forward_agent => true}

set :use_sudo, false

set :keep_releases, 5
set :log_level, :debug

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

SSHKit.config.command_map[:rake]  = "bundle exec rake"

namespace :deploy do
  task :restart do
    on roles(:app) do
      if test("[ -e #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]")
        execute "kill -USR2 `cat #{fetch(:unicorn_pid)}`"
      else
        within release_path do
          with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
            execute :bundle, "exec unicorn_rails -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D"
          end
        end
      end
    end
  end

  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec unicorn_rails -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D"
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      execute "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -QUIT `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end

  task :make_symlink do
    on roles(:app) do |host|
      execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  # config
  task :copy_conf_files do
    on roles(:app) do |host|
      execute "cp -f #{release_path}/config/deploy/#{fetch(:stage)}/unicorn.rb #{release_path}/config/"
      execute "cp -f #{release_path}/config/deploy/#{fetch(:stage)}/application.yml #{release_path}/config/"
      execute "cp -f #{release_path}/config/deploy/#{fetch(:stage)}/robots.txt #{release_path}/public/"
    end
  end

  after :finishing, "deploy:cleanup"
end

namespace :scheduler do
  desc "scheduler:start"
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec ruby lib/scheduler.rb start"
        end
      end
    end
  end
  desc "scheduler:stop"
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec ruby lib/scheduler.rb stop"
        end
      end
    end
  end
  desc "scheduler:restart"
  task :restart do
    invoke 'scheduler:stop'
    invoke 'scheduler:start'
  end
end

namespace :resque do
  desc "resque:start"
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec rake resque:start"
        end
      end
    end
  end
  desc "resque:stop"
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec rake resque:stop"
        end
      end
    end
  end
  desc "resque:restart"
  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec rake resque:restart"
        end
      end
    end
  end
end

namespace :background do
  desc "background::restart"
  task :restart do
  #   if fetch(:monit_restart)
  #     desc "use monit for restart backgroung processes"
  #     # Use passwordless approach: on server side you need to do the next command:
  #     # sudo visudo -f /etc/sudoers
  #     # # Add the next line to the end of file
  #     # USER ALL=(ALL) NOPASSWD:monit -g letsfly restart all
  #     on roles(:app) do
  #       execute :sudo, "monit -g letsfly restart all"
  #     end
  #   else
      invoke 'deploy:restart'
      # invoke 'scheduler:restart'
      # invoke 'resque:restart'
    # end
  end

  after :restart, :clear_cache do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :rake, 'stuff:clear_cache'
        end
      end
    end
  end
end

namespace :bundler do
  task :bundle_new_release do
    on roles(:app) do
      shared_dir = File.join(shared_path, 'bundle')
      release_dir = File.join(release_path, '.bundle')
      execute "mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}"
      execute %Q{cd #{release_path} && echo "rvm use #{fetch(:rvm_ruby_version)} --create" > .rvmrc}
      execute :rvm, "rvmrc trust #{release_path}"
      # execute "bundle install --binstubs"
    end
  end
end

before "deploy:updated", "deploy:copy_conf_files"
before "deploy:updated", "deploy:make_symlink"
after 'deploy:publishing', 'background:restart'

# after 'deploy:publishing', 'deploy:restart'
# after 'deploy:publishing', 'scheduler:restart'
# after 'deploy:publishing', 'resque:restart'

after 'deploy:publishing', 'bundler:bundle_new_release'
