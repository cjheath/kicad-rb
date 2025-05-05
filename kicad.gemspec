# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kicad/version'

Gem::Specification.new do |spec|
  spec.name          = "kicad"
  spec.version       = KiCad::VERSION
  spec.authors       = ["Clifford Heath"]
  spec.email         = ["clifford.heath@gmail.com"]

  spec.summary       = %q{Load and rewrite Kicad s-expression files into a tree structure for scripting}
  spec.description   = %q{Load and rewrite Kicad s-expression files into a tree structure for scripting}
  spec.homepage      = "https://github.com/cjheath/kicad"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.11"
  spec.add_development_dependency "rake", ">= 13"
  spec.add_development_dependency "rspec", "~> 3.3"

  spec.add_runtime_dependency "treetop", ["~> 1.6", ">= 1.6.9"]
  spec.add_runtime_dependency "irb", ["~> 1.14", ">= 1.14"]
end
