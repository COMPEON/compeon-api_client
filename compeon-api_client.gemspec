lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compeon/api_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'compeon-api_client'
  spec.version       = Compeon::ApiClient::VERSION
  spec.authors       = ['Timo Schilling']
  spec.email         = ['timo@schilling.io']

  spec.summary       = 'COMPEON API Client'
  spec.description   = 'COMPEON API Client'
  spec.homepage      = 'https://github.com/COMPEON/compeon-api_client'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
