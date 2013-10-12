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
set :pty, true

set :rvm_type, :user

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}

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
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

  after :finishing, 'deploy:cleanup'
end

# namespace :deploy do
#   task :default do
#     update
#     assets.precompile
#     restart
#     cleanup
#     # etc
#   end
# end
#  
# namespace :assets do
#   desc "Precompile assets locally and then rsync to app servers"
#   task :precompile, :only => { :primary => true } do
#     run_locally "mkdir -p public/__assets; mv public/__assets public/assets;"
#     run_locally "bundle exec rake assets:clean_expired; bundle exec rake assets:precompile;"
#     servers = find_servers :roles => [:app], :except => { :no_release => true }
#     servers.each do |server|
#       run_locally "rsync -av ./public/assets/ #{user}@#{server}:#{current_path}/public/assets/;"
#     end
#     run_locally "mv public/assets public/__assets"
#   end
# end