# frozen_string_literal: true

module Rack::BlastWave
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @since 0.1.0
  CacheUtilityError = Class.new(Error)
  # @since 0.1.0
  UnsupportedDriverError = Class.new(CacheUtilityError)
end
