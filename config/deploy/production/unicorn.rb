deploy_to  = "/home/rails/"
rails_root = "#{deploy_to}"
pid_file   = "/home/unicorn/pids/unicorn.pid"
socket_file= "/home/unicorn/unicorn.sock"
log_file   = "#{rails_root}/log/production.log"
old_pid    = pid_file + '.oldbin'

timeout 100
worker_processes 2
listen socket_file, :backlog => 1024
pid pid_file
stderr_path log_file
stdout_path log_file

preload_app true

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end