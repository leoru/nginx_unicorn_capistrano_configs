# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
@dir = "/var/www/my_rails_app/current/"
@shared_dir = "/var/www/my_rails_app/shared/"
worker_processes 2
working_directory @dir
preload_app true
timeout 30

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "#{@shared_dir}tmp/sockets/unicorn.sock", :backlog => 64

# Set process id path
pid "#{@shared_dir}tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{@shared_dir}log/unicorn.stderr.log"
stdout_path "#{@shared_dir}log/unicorn.stdout.log"


# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end


before_fork do |server, worker|
  old_pid = '{@shared_dir}tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end

