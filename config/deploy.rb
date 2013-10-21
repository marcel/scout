set :application, "scout"
set :repository,  "git@github.com:marcel/scout.git"

role :all,'scout@scoutrank.co'
role :app,'scout@scoutrank.co'
role :web,'scout@scoutrank.co'
role :db, 'scout@scoutrank.co'
after "deploy:restart", "deploy:cleanup"

require "rvm/capistrano"
require "bundler/capistrano"
# require 'capistrano-unicorn'

set :user, 'scout'
set :repo_url, 'git@github.com:marcel/scout.git'

set :branch, 'master'
set :deploy_to, "/home/scout/production"

set :deploy_via, :remote_cache
set :scm, :git

set :format, :pretty
set :log_level, :debug

set :rvm_type, :user
set :rvm_path, '/usr/local/rvm'
set :use_sudo, false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# N.B. if github cloning returns ssh key issues run:
#   ssh-add ~/.ssh/id_rsa
#   ssh-add ~/.ssh/id_dsa

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

task :unicorn_restart do
  run 'service unicorn restart'
end
after 'deploy:restart', 'unicorn_restart'

namespace :import do
  desc "Import armchair analysis zip (use '-s zip=path/to/archive.zip' to specify path)"
  task :armchair_analysis do
    abort("Specify path to zip file with '-s zip=path'") unless zip
    path_to_zip = File.expand_path(zip)
    zip_file = File.basename(path_to_zip)

    working_dir = File.join('/tmp', release_name)
    script = 'armchair-analysis.rb'
    script_path = File.expand_path(File.join(File.dirname(__FILE__), "/../bin/#{script}"))
    run "mkdir #{working_dir}"
    
    remote_script = File.join(working_dir, script)
    remote_zip    = File.join(working_dir, zip_file)
    upload(script_path, remote_script, roles: :db)
    upload(path_to_zip, remote_zip, roles: :db)
    run "cd #{working_dir} && unzip #{remote_zip} && /usr/bin/env ruby #{script} import scout_production"
    run "rm -rf #{working_dir}"
  end
end

# namespace :import do
#   task :all do
#     on roles(:app) do
#       within release_path do
#         execute :rake, "RAILS_ENV=production import:all"
#       end
#     end
#   end
# end

# namespace :deploy do
#   %w[start stop restart].each do |command|
#     desc "#{command} unicorn server"
#     task command.to_sym do
#       on roles(:app) do
#         execute "service unicorn #{command}"
#       end
#     end
#   end
#
#   # after :restart, :clear_cache do
#   #   on roles(:web), in: :groups, limit: 3, wait: 10 do
#   #     # Here we can do anything such as:
#   #     within release_path do
#   #       execute :rake, 'cache:clear'
#   #     end
#   #   end
#   # end
#
#   after :finishing, 'deploy:cleanup'
# end
