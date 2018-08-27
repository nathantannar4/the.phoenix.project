# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "application_name"
set :repo_url, "https://github.com/username/repo.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/application_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do

    desc "Push local changes to Git repository"
    task :push do
  
      # Check for any local changes that haven't been committed
      # Use 'cap deploy:push IGNORE_DEPLOY_RB=1' to ignore changes to this file (for testing)
      status = %x(git status --porcelain).chomp
      if status != ""
        puts "Local git repository has uncommitted changes"
        set :commit_message, ask("Commit Message (or input skip to skip)", Time.now.strftime("%d/%m/%Y %H:%M"))
        if fetch(:commit_message) != 'skip'
            run_locally do
                execute "git add -A"
                execute "git commit -m '#{fetch(:commit_message)}'"
            end
        end
      end
  
        # Check we are on the master branch, so we can't forget to merge before deploying
        branch = %x(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\1/').chomp
        if branch != "master" && !ENV["IGNORE_BRANCH"]
            raise "Not on master branch (set IGNORE_BRANCH=1 to ignore)"
        end

        # Push the changes
        if ! system "git push #{fetch(:repo_url)} master"
            raise "Failed to push changes to #{fetch(:repo_url)}"
        end
  
    end

    if !ENV["NO_PUSH"]
        before "deploy", "deploy:push"
    end
    
    # This method changes to our latest deploy directory and fetches the dependencies using the Vapor Toolbox
    desc 'Fetch Dependencies'
    task :dependencies do
        on roles(:app) do
            execute("cd #{fetch(:deploy_to)}/current && vapor fetch --verbose")
        end
    end

    # This method changes to our latest deploy directory and builds our app using the release configuration using the Vapor Toolbox
    desc 'Build Vapor App'
    task :build do
        on roles(:app) do
            execute("cd #{fetch(:deploy_to)}/current && vapor build --release --verbose")
        end
    end

    after :publishing, 'deploy:dependencies'
    after :publishing, 'deploy:build'


    desc 'Start Vapor App'
    task :start do
        on roles(:app) do
            execute(:sudo, 'systemctl', :start, :application)
        end
    end

    desc 'Stop Vapor App'
    task :stop do
        on roles(:app) do
            execute(:sudo, 'systemctl', :stop, :application)
        end
    end

    desc 'Restart Vapor App'
    task :restart do
        on roles(:app) do
            execute(:sudo, 'systemctl', :restart, :application)
        end
    end

    # Add this line below after :publishing, 'deploy:build'
    after :publishing, 'deploy:restart'

end
