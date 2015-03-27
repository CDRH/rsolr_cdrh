# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsolr_cdrh/version'

Gem::Specification.new do |spec|
  spec.name          = "rsolr_cdrh"
  spec.version       = RSolrCdrh::VERSION
  spec.authors       = ["Jessica Dussault (jduss4)"]
  spec.email         = ["jdussault@unl.edu"]
  spec.summary       = %q{Wrapper for solr to cut down on repetition between similar projects}
  spec.description   = %q{The Center for Digital Research in the Humanities 
                          uses a standard TEI (Text Encoding Initiative) Solr schema.
                          This gem is for avoiding repeating logic when querying solr 
                          from CDRH sites.  Includes methods like "get_item_by_id", a
                          facet response processor, and default query settings.
                          Methods in this gem should be widely applicable
                          for those who wish to adopt it. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.7"
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "rsolr", "~> 1.0"

  spec.add_development_dependency "rspec", "~> 3.2"
end
