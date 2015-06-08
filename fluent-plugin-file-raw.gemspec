# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-file-raw"
  spec.version       = "0.0.1"
  spec.authors       = ["takahiro.nakayama"]
  spec.email         = ["civitaspo@gmail.com"]

  spec.summary       = %q{Fluentd plugin to output raw data to files.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/civitaspo/fluent-plugin-file-raw"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"

end
