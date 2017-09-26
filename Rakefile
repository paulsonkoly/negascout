require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

namespace :yard do
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/*.rb']
    t.options = ['--no-private']
    t.stats_options = ['--no-private', '--list-undoc']
  end

  task :publish => :yard do
    Dir.mktmpdir do |d|
      cp_r 'doc/.', d
      cp 'negascout.gemspec', d
      sh "git checkout gh-pages"
      cp_r "#{d}/.", './'
      sh 'git add .'
      sh 'git commit -m "updating docs"'
      sh 'git checkout master'
    end
  end
end

task :clobber do
  rm_rf 'doc'
end

task :default => :spec
