# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid_paging_token/version'

Gem::Specification.new do |s|
  s.name        = 'mongoid_paging_token'
  s.version     = MongoidPagingToken::VERSION
  s.authors     = ['Paul Walker']
  s.email       = ['github@paulwalker.tv']
  s.homepage    = ''
  s.summary     = 'An extension the generates a serialized Mongoid::Criteria for use as a paging token'
  s.description = ''
  s.license     = 'MIT'

  s.rubyforge_project = 'mongoid_paging_token'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'mongoid', '~> 3.1.6'
end