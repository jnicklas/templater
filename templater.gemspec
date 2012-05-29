# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{templater}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = Date.today.to_s
  s.description = %q{Templater has the ability to both copy files from A to B and also to render templates using ERB. Templater consists of four parts:

- Actions (File copying routines, templates generation and directories creation routines).
- Generators (set of rules).
- Manifolds (generator suites).
- The command line interface.

Hierarchy is pretty simple: manifold has one or many public and private generators. Public ones are supposed to be called
by end user. Generators have one or more action that specify what they do, where they take files, how they name resulting
files and so forth.}
  s.email = ["jonas.nicklas@gmail.com"]

  s.files = Dir[
    "History.txt",
    "Manifest.txt",
    "README.rdoc",
    "Rakefile",
    '{lib,spec,script}/**/*'
  ]

  s.homepage = %q{http://github.com/jnicklas/templater}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{templater}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Templater has the ability to both copy files from A to B and also to render templates using ERB}

  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'highline', '>= 1.4.0'
  s.add_dependency 'diff-lcs', '>= 1.1.2'

  s.add_development_dependency 'rspec', '>= 2.6'
end
