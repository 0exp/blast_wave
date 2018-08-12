# frozen_string_literal: true

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start { add_filter 'spec' }

require 'bundler/setup'
require 'blast_wave'
require 'rack/test'
require 'pry'

require_relative 'support/fake_app'
require_relative 'support/request_helpers'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed

  config.include Rack::Test::Methods
  config.include SpecSupport::FakeApp
  config.include SpecSupport::RequestHelpers
end
