require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "svengali"
    gem.summary = "distributed machine operating library of cloud age. please see http://sourceforge.jp/projects/svengali/wiki/FrontPage"
    gem.description = "Svengali offers means to manage and operate distributed machines easier than by other tools like shell script"
    gem.email = "ryo.contact [at] gmail.com"
    gem.homepage = "http://sourceforge.jp/projects/svengali/"
    gem.authors = ["Ryo Kanbayashi"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "net-ssh", ">= 2.0.17"
    gem.add_dependency "net-sftp", ">= 2.0.4"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "svengali #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
