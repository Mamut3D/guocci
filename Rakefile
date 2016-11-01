# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: :spec

desc 'Run acceptance tests (RSpec + Rubocop)'
task test: 'acceptance'

desc 'Run acceptance tests (RSpec + Rubocop)'
task :acceptance do |_t|
  Rake::Task['spec'].invoke
  Rake::Task['rubocop'].invoke
end
