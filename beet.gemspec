# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{beet}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jack Dempsey"]
  s.date = %q{2009-05-20}
  s.default_executable = %q{beet}
  s.email = %q{jack.dempsey@gmail.com}
  s.executables = ["beet"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "beet.gemspec",
     "bin/beet",
     "lib/beet.rb",
     "lib/beet/capistrano.rb",
     "lib/beet/commands.rb",
     "lib/beet/execution.rb",
     "lib/beet/executor.rb",
     "lib/beet/file_system.rb",
     "lib/beet/interaction.rb",
     "lib/beet/logging.rb",
     "lib/beet/rails.rb",
     "lib/beet/scm.rb",
     "lib/beet/scm/git.rb",
     "lib/beet/scm/svn.rb",
     "lib/beet/templates/rails/clean_files.rb",
     "lib/beet/templates/rails/git.rb",
     "lib/beet/templates/rails/jquery.rb",
     "spec/beet_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jackdempsey/beet}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A gem to help with easily generating projects}
  s.test_files = [
    "spec/beet_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
