# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class RedisStore < Redis
      class << self
        # @param driver [Object]
        # @return [Boolean]
        #
        # @api private
        # @since 0.1.0
        def supported_driver?(driver)
          defined?(::Redis::Store) && driver.is_a?(::Redis::Store)
        end
      end

      # @param key [String]
      # @param options [Hash]
      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      def read(key, **options)
        get(key, raw: true)
      end

      # @param key [String]
      # @param value [Object]
      # @option expires_in [NilClass, Integer] Time in seconds
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def write(key, value, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

        expires_in ? setex(key, expires_in, value, raw: true) : set(key, value, raw: true)
      end
    end
  end
end
