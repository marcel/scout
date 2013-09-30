namespace :db do  
  desc "List all tables and the number of rows in each"
  task :counts  do
    Scout::Server.load_models
    
    models = ActiveRecord::Base.subclasses.sort_by(&:name)
        
    row_counts_per_model = models.inject({}) do |counts, model|
      counts[model.name[/\w+$/]] = model.count
      counts
    end
    
    padding = row_counts_per_model.keys.max_by(&:size).size
    sorted  = row_counts_per_model.sort_by(&:count)
    
    sorted.each do |model, count|
      puts "#{model.rjust(padding)} #{count}"
    end
  end
end