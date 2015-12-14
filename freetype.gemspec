# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freetype/version'

Gem::Specification.new do |spec|
  spec.name          = 'freetype'
  spec.version       = FreeType::VERSION
  spec.authors       = ['ksss']
  spec.email         = ['co000ri@gmail.com']

  spec.summary       = 'FreeType binding by ffi'
  spec.description   = 'FreeType binding by ffi'
  spec.homepage      = 'https://github.com/ksss/freetype'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'ffi'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rgot'
end
