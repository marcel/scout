namespace :import do
  Scout::Server.load_models

  importing_models = ActiveRecord::Base.subclasses.select do |model|
    model.singleton_methods.include?(:import)
  end

  week = ENV['WEEK'] ? ENV['WEEK'].to_i : GameWeek.current.week

  importing_models.each do |importing_model|
    desc "Import #{importing_model.name}"
    task importing_model.name.pluralize.underscore.to_sym do
      importing_model.import(week)
    end
  end

  desc 'Import all'
  task all: importing_models.map {|model| model.name.pluralize.underscore.to_sym }
end