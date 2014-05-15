# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imgur/version'

Gem::Specification.new do |spec|
  spec.name          = 'imgur'
  spec.version       = Imgur::VERSION
  spec.authors       = ['August']
  spec.email         = ['augustt198@gmail.com']
  spec.description   = %q{Imgur API wrapper}
  spec.summary       = %q{Imgur API wrapper}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'httparty'

end
