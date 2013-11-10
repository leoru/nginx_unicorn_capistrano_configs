
require 'capistrano/bundler'
require 'capistrano/rvm'

set :application, 'sample_project'
set :repo_url, 'git@bitbucket.org:sample_username/sample_project.git'
set :branch, 'master'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/sample_project'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5
namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'deploy:unicorn:restart'
  end


  namespace :unicorn do
    pid_path = "#{release_path}/tmp/pids"
    unicorn_pid = "#{pid_path}/unicorn.pid"

    def run_unicorn
      execute "#{fetch(:bundle_binstubs)}/unicorn", "-c #{release_path}/config/unicorn.rb -D -E #{fetch(:stage)}"
    end

    desc 'Start unicorn'
    task :start do
      on roles(:app) do
        run_unicorn
      end
    end

    desc 'Stop unicorn'
    task :stop do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-QUIT `cat #{unicorn_pid}`"
        end
      end
    end

    desc 'Force stop unicorn (kill -9)'
    task :force_stop do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-9 `cat #{unicorn_pid}`"
          execute :rm, unicorn_pid
        end
      end
    end

    desc 'Restart unicorn'
    task :restart do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-USR2 `cat #{unicorn_pid}`"
        else
          run_unicorn
        end
      end
    end
  end

end
