# -*- encoding: utf-8 -*-
# stub: bundler-unload 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "bundler-unload".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michal Papis".freeze]
  s.date = "2013-09-22"
  s.email = ["mpapis@gmail.com".freeze]
  s.homepage = "https://github.com/mpapis/bundler-unload".freeze
  s.licenses = ["Apache 2.0".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Allow unloading bundler after Bundler.load".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
