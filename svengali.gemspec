# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{svengali}
  s.version = "0.2.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryo Kanbayashi"]
  s.date = %q{2010-09-11}
  s.description = %q{Svengali offers means to manage and operate distributed machines easier than by other tools like shell script}
  s.email = %q{ryo.contact [at] gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "api_document020_en.pdf",
     "api_document020_ja.pdf",
     "api_document_en.pptx",
     "api_document_ja.pptx",
     "lib/svengali.rb",
     "lib/svengali/config.rb",
     "lib/svengali/ext_string.rb",
     "lib/svengali/ext_string/command.yml",
     "lib/svengali/ext_string/path.yml",
     "lib/svengali/file_io.rb",
     "lib/svengali/machine.rb",
     "lib/svengali/platforms/debian.rb",
     "lib/svengali/platforms/default.rb",
     "lib/svengali/plugins/eucalyptus.rb",
     "lib/svengali/plugins/machine_config.rb",
     "lib/svengali/plugins/package.rb",
     "lib/svengali/ssh.rb",
     "lib/svengali/svengali.rb",
     "lib/svengali/util.rb",
     "rdoc/classes/CLibIPAddr.html",
     "rdoc/classes/Cloud.html",
     "rdoc/classes/Config.html",
     "rdoc/classes/Config/ConfigFile.html",
     "rdoc/classes/ExtStr.html",
     "rdoc/classes/ExtStrAccessor.html",
     "rdoc/classes/FileIO.html",
     "rdoc/classes/Machine.html",
     "rdoc/classes/MachineMaster.html",
     "rdoc/classes/Platform.html",
     "rdoc/classes/SSH.html",
     "rdoc/created.rid",
     "rdoc/files/README.html",
     "rdoc/files/README_rdoc.html",
     "rdoc/files/lib/svengali/config_rb.html",
     "rdoc/files/lib/svengali/ext_string_rb.html",
     "rdoc/files/lib/svengali/file_io_rb.html",
     "rdoc/files/lib/svengali/machine_rb.html",
     "rdoc/files/lib/svengali/platforms/debian_rb.html",
     "rdoc/files/lib/svengali/platforms/default_rb.html",
     "rdoc/files/lib/svengali/plugins/eucalyptus_rb.html",
     "rdoc/files/lib/svengali/plugins/machine_config_rb.html",
     "rdoc/files/lib/svengali/plugins/package_rb.html",
     "rdoc/files/lib/svengali/ssh_rb.html",
     "rdoc/files/lib/svengali/svengali_rb.html",
     "rdoc/files/lib/svengali/util_rb.html",
     "rdoc/files/lib/svengali_rb.html",
     "rdoc/fr_class_index.html",
     "rdoc/fr_file_index.html",
     "rdoc/fr_method_index.html",
     "rdoc/index.html",
     "rdoc/rdoc-style.css",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/svengali_spec.rb",
     "svengali.gemspec",
     "svengali_sample.rb",
     "test/scenario.sh"
  ]
  s.homepage = %q{http://sourceforge.jp/projects/svengali/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{distributed machine operating library of cloud age. please see http://sourceforge.jp/projects/svengali/wiki/FrontPage}
  s.test_files = [
    "spec/svengali_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.17"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.4"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<net-ssh>, [">= 2.0.17"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<net-ssh>, [">= 2.0.17"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
  end
end

