# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-ei-recipes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['David Aaron Fendley']
  gem.email         = ['tricon@me.com']
  gem.description   = %q{Common Capistrano recipes used at Elemental Imaging.}
  gem.summary       = %q{Common EI capistrano recipes.}
  gem.homepage      = 'http://elemental-imaging.com'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'capistrano-ei-recipes'
  gem.require_paths = ['lib']
  gem.version       = CapistranoEiRecipes::VERSION

  gem.add_dependency 'capistrano'
  gem.add_dependency 'capistrano-ext'
end
