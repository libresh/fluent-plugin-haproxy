lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-haproxy"
  spec.version = "0.1.0"
  spec.authors = ["pierreozoux"]
  spec.email   = ["pierre@ozoux.net"]

  spec.summary       = "An haproxy log parser"
  spec.description   = "An haproxy log parser"
  spec.homepage      = "https://github.com/libresh/fluent-plugin-haproxy"
  spec.license       = "AGPL-3.0"

  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
