# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "web_crawler/version"

Gem::Specification.new do |s|
  s.name        = "web_crawler"
  s.version     = WebCrawler::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Anton Sozontov"]
  s.email       = ["a.sozontov@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Web crawler help you with parse and collect data from the web}
  s.description = %q{Web crawler help you with parse and collect data from the web}

  s.rubyforge_project = "web_crawler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = false

  s.bindir = "bin"
  s.executables << "wcrawler"

  s.add_dependency 'thor'

  s.add_development_dependency(%q<rspec>, [">=2.6"])
  s.add_development_dependency(%q<fakeweb>)
end
