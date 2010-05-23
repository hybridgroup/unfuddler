require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "unfuddler"
    gem.summary = %Q{Provides a simple Ruby API to Unfuddle.}
    gem.description = %Q{Provides a simple Ruby API to Unfuddle.}
    gem.email = "sirup@sirupsen.dk"
    gem.homepage = "http://github.com/Sirupsen/unfuddler"
    gem.authors = ["Sirupsen"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_dependency "hashie", ">= 0.2.0"
    gem.add_dependency "crack", ">= 0.1.6"
    gem.add_dependency "activesupport", ">= 2.3.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "unfuddler #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
