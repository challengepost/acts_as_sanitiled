require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "acts_as_sanitiled"
    gem.summary = %Q{Automatically textiles and/or sanitizes ActiveRecord columns}
    gem.description = %Q{A modernized version of Chris Wansthrath's venerable acts_as_textiled. It automatically textiles and then sanitizes columns to your specification.  Ryan Grove's excellent Sanitize gem with nokogiri provides the backend for speedy and robust filtering of your output in order to: restrict Textile to a subset of HTML, guarantee well-formedness, and of course prevent XSS.}
    gem.email = "gabe@websaviour.com"
    gem.homepage = "http://github.com/dasil003/acts_as_sanitiled"
    gem.authors = ["Gabe da Silveira"]

    gem.add_dependency('nokogiri', '~> 1.4.1')
    gem.add_dependency('sanitize', '~> 1.1.0')
    gem.add_dependency('RedCloth')

    gem.add_development_dependency "bacon"
    gem.add_development_dependency "activesupport"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "acts_as_sanitiled #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end