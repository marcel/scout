require 'capistrano/rails'
require "rvm/capistrano"

set :application, 'scout'
set :user, 'scout'
set :repo_url, 'git@github.com:marcel/scout.git'

set :branch, 'master'
set :deploy_to, "/home/scout/production"

set :deploy_via, :remote_cache
set :scm, :git

set :format, :pretty
set :log_level, :debug

set :rvm_type, :user

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}

task :foo do
  on roles(:app) do
    execute "whoami"
    execute "cd /home/scout/production/current; pwd"
    execute "which rake"
    execute "which bundle"
    execute "which ruby"
    execute "ruby -v"
    execute "env"
  end
end

namespace :import do
  task :all do
    on roles(:app) do
      within release_path do
        execute :rake, "RAILS_ENV=production import:all"
      end
    end
  end
end

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command.to_sym do
      on roles(:app) do
        execute "service unicorn #{command}"
      end
    end
  end

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     within release_path do
  #       execute :rake, 'cache:clear'
  #     end
  #   end
  # end

  after :finishing, 'deploy:cleanup'
end
