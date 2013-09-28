require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.dirname(__FILE__) + '/lib/scout'

task :default => :test

Rake::TestTask.new do |test|
  test.pattern = 'test/*_test.rb'
end

namespace :db do
  desc "List all tables and the number of rows in each"
  task :counts do 
    models = []
    ObjectSpace.each_object(Class) do |subclass|
      models << subclass if subclass.superclass == ActiveRecord::Base
    end
    
    row_counts_per_model = models.inject({}) do |counts, model|
      counts[model.name] = model.count
      counts
    end
    
    padding = row_counts_per_model.keys.max_by(&:size).size
    sorted  = row_counts_per_model.sort_by(&:count)
    
    sorted.each do |model, count|
      puts "#{model.rjust(padding)} #{count}"
    end
  end
  
  namespace :import do
    # TODO implement
    desc "Import projections"
    task :projections
  end
  
  MIGRATIONS_DIRECTORY = Scout::data_dir + "migrations"
  SCHEMA_FILE          = Scout::data_dir + "schema.rb"
  
  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    migration_version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    ActiveRecord::Migrator.migrate(MIGRATIONS_DIRECTORY, migration_version)

    Rake::Task['db:schema:dump'].invoke
  end
  
  desc "Rollback migration"
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(MIGRATIONS_DIRECTORY, step)
    Rake::Task['db:schema:dump'].invoke
  end
  
  namespace :schema do 
    task :dump do
      File.open(SCHEMA_FILE, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end