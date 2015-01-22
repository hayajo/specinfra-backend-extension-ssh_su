# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'specinfra/backend/extension/ssh_su/version'

Gem::Specification.new do |spec|
  spec.name          = "specinfra-backend-extension-ssh_su"
  spec.version       = Specinfra::Backend::Extension::SshSu::VERSION
  spec.authors       = ["hayajo"]
  spec.email         = ["hayajo@cpan.org"]
  spec.summary       = %q{SSH + su backend for specinfra.}
  spec.description   = %q{SSH + su backend for specinfra.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "specinfra", "~> 2.11.5"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
end
