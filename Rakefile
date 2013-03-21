require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |g|
    g.name = 'belongs_to_versioned'
    g.summary = %(Simplify associations using vestal_versions or acts_as_versioned)
    g.description = %(Simplify associations using vestal_versions or acts_as_versioned)
    g.email = 'steve@laserlemon.com'
    g.homepage = 'http://github.com/laserlemon/belongs_to_versioned'
    g.authors = %w(laserlemon)
    g.rubyforge_project = 'laser-lemon'
  end
  Jeweler::RubyforgeTasks.new do |r|
    r.doc_task = 'rdoc'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com'
end

Rake::TestTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/**/*_test.rb'
end

task :default => :test

Rake::RDocTask.new do |r|
  version = File.exist?('VERSION') ? File.read('VERSION') : nil
  r.rdoc_dir = 'rdoc'
  r.title = ['belongs_to_versioned', version].compact.join(' ')
  r.rdoc_files.include('README*')
  r.rdoc_files.include('lib/**/*.rb')
end
