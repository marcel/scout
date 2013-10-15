set :stage, :production

role :all, %w[scout@scoutrank.co]
role :app, %w[scout@scoutrank.co]
role :web, %w[scout@scoutrank.co]
role :db, %w[scout@scoutrank.co]

namespace :import do 
  desc "Import armchair analysis zip (use 'ZIP=path/to/archive.zip' to specify path)"
  task :armchair_analysis, :zip_file do
    abort("Specify 'ZIP' env variable") unless zip = ENV['ZIP']
    working_dir = File.join('/tmp', release_timestamp)
    script = 'armchair-analysis.rb'
    script_path = File.join(File.dirname(__FILE__), "/../../bin/#{script}")
    
    on roles(:db) do
      execute :mkdir, working_dir
      
      system("scp '#{script_path}' '#{zip}' scout@scoutrank.co:'#{working_dir}'")
      
      within working_dir do
        execute :unzip, zip
        execute :ruby, "#{script} import scout_production"
      end
    end
  end
end