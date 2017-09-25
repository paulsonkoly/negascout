require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/*.rb']
  t.options = ['--no-private']
  t.stats_options = ['--no-private', '--list-undoc']
end

task :clobber do
  rm_rf 'doc'
end

task :default => :spec
