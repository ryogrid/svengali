# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{svengali}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryo Kanbayashi"]
  s.date = %q{2010-09-09}
  s.description = %q{User can manage and operate distributed machines easier than by other tools like shell script}
  s.email = %q{ryo.contact [at] gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "README.rdoc"
  ]
  s.files = [
    "README",
     "api_document020_en.pdf",
     "api_document020_ja.pdf",
     "api_document_en.pptx",
     "api_document_ja.pptx",
     "svengali/config.rb",
     "svengali/ext_string.rb",
     "svengali/ext_string/command.yml",
     "svengali/ext_string/path.yml",
     "svengali/file_io.rb",
     "svengali/machine.rb",
     "svengali/platforms/debian.rb",
     "svengali/platforms/default.rb",
     "svengali/plugins/eucalyptus.rb",
     "svengali/plugins/machine_config.rb",
     "svengali/plugins/package.rb",
     "svengali/ssh.rb",
     "svengali/svengali.rb",
     "svengali/util.rb",
     "svengali_sample.rb"
  ]
  s.homepage = %q{http://github.com/ryogrid/svengali}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Svengali is distributed machine operating library of cloud age}
  s.test_files = [
    "spec/svengali_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end
