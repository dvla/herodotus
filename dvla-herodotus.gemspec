require_relative 'lib/dvla/herodotus/version'

Gem::Specification.new do |spec|
  spec.name          = 'dvla-herodotus'
  spec.version       = DVLA::Herodotus::VERSION
  spec.authors       = ['Driver and Vehicle Licensing Agency (DVLA)', 'George Bell']
  spec.email         = ['george.bell.contractor@dvla.gov.uk']

  spec.summary       = 'Provides a lightweight logger with a common format'
  spec.required_ruby_version = Gem::Requirement.new('>= 3')
  spec.homepage      = 'https://github.com/dvla/herodotus'

  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'rspec', '~> 3.8'
end
