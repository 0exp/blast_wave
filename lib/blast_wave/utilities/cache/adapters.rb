# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  module BlastWave::Utilities::Cache::Adapters
    require_relative 'adapters/basic'
    require_relative 'adapters/delegator'
    require_relative 'adapters/dalli'
    require_relative 'adapters/redis'
    require_relative 'adapters/redis_store'
    require_relative 'adapters/active_support_file_store'
    require_relative 'adapters/active_support_redis_cache_store'

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
        when redis_store?(driver)
          BlastWave::Utilities::Cache::Adapters::RedisStore.new(driver)
        when redis?(driver)
          BlastWave::Utilities::Cache::Adapters::Redis.new(driver)
        when dalli?(driver)
          BlastWave::Utilities::Cache::Adapters::Dalli.new(driver)
        when active_support_file_store?(driver)
          BlastWave::Utilities::Cache::Adapters::ActiveSupportFileStore.new(driver)
        when active_support_redis_cache_store?(driver)
          BlastWave::Utilities::Cache::Adapters::ActiveSupportRedisCacheStore.new(driver)
        when delegateable?(driver)
          BlastWave::Utilities::Cache::Adapters::Delegator.new(driver)
        else
          raise BlastWave::UnsupportedDriverError
        end
      end

      private

      def redis_store?(driver)
        RedisStore.supported_driver?(driver)
      end

      def redis?(driver)
        Redis.supported_driver?(driver)
      end

      def dalli?(driver)
        Dalli.supported_driver?(driver)
      end

      def active_support_file_store?(driver)
        ActiveSupportFileStore.supported_driver?(driver)
      end

      def active_support_redis_cache_store?(driver)
        ActiveSupportRedisCacheStore.supported_driver?(driver)
      end

      def delegateable?(driver)
        Delegator.supported_driver?(driver)
      end
    end
  end
end
