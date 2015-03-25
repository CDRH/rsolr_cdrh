# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsolr_tei/version'

Gem::Specification.new do |spec|
  spec.name          = "rsolr_tei"
  spec.version       = RsolrTei::VERSION
  spec.authors       = ["Jessica Dussault"]
  spec.email         = ["jdussault@unl.edu"]
  spec.summary       = %q{Provides a wrapper for rsolr specific to querying a standard TEI API}
  spec.description   = %q{The Center for Digital Research in the Humanities 
                          uses a standard TEI (Text Encoding Initiative) Solr schema.
                          This gem is for avoiding repeating logic when
                          querying solr from CDRH Sinatra sites.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rsolr", "~> 1.0.12"
end
