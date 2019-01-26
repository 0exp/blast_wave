# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blast_wave/version'

Gem::Specification.new do |spec|
  spec.name          = 'blast_wave'
  spec.version       = Rack::BlastWave::VERSION
  spec.authors       = ['Rustam Ibragimov']
  spec.email         = ['iamdaiver@icloud.com']
  spec.summary       = 'Soon'
  spec.description   = 'Soon'
  spec.homepage      = 'https://github.com/0exp/blast_wave'
  spec.license       = 'MIT'

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  end

  spec.add_dependency 'rack',            '~> 2.0'
  spec.add_dependency 'qonfig',          '~> 0.9'
  spec.add_dependency 'concurrent-ruby', '~> 1.0'

  spec.add_development_dependency 'coveralls',        '~> 0.8'
  spec.add_development_dependency 'simplecov',        '~> 0.16'
  spec.add_development_dependency 'armitage-rubocop', '~> 0.18'
  spec.add_development_dependency 'rspec',            '~> 3.8'
  spec.add_development_dependency 'rack-test',        '~> 1.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
