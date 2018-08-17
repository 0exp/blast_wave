# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  module BlastWave::Utilities::Cache::Adapters
    require_relative 'adapters/basic'
    require_relative 'adapters/dalli'
    require_relative 'adapters/redis'
    require_relative 'adapters/redis_store'

    class << self
      # @param driver [Object]
      # @return [BlastWave::Utilities::Cache::Adapters::Basic]
      #
      # @raise [BlastWave::UnsupportedDriverError]
      #
      # @api private
      # @since 0.1.0
      def build(driver)
        case
        when defined?(::Redis) && defined?(::Redis::Store) && driver.is_a?(::Redis::Store)
          BlastWave::Utilities::Cache::Adapters::RedisStore.new(driver)
        when defined?(::Redis) && driver.is_a?(::Redis)
          BlastWave::Utilities::Cache::Adapters::Redis.new(driver)
        when defined?(::Dalli) && defined?(::Dalli::Client) && driver.is_a?(::Dalli::Client)
          BlastWave::Utilities::Cache::Adapters::Dalli.new(driver)
        else
          raise BlastWave::UnsupportedDriverError
        end
      end
    end
  end
end
