# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class Basic
      # @since 0.1.0
      extend Forwardable

      class << self
        # @param driver [Object]
        # @return [Boolean]
        #
        # @api private
        # @since 0.1.0
        def supported_driver?(driver)
          false
        end
      end

      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      attr_reader :driver

      # @param driver [Object]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def initialize(driver)
        @driver = driver
      end

      # @param key [String]
      # @param options [Hash]
      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      def read(key, **options)
        raise NotImplementedError
      end

      # @param key [String]
      # @param value [Object]
      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @sinc 0.1.0
      def write(key, value, **options)
        raise NotImplementedError
      end

      # @param key [String]
      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def delete(key, **options)
        raise NotImplementedError
      end

      # @param key [String]
      # @param value [Integer, Float]
      # @param options [Hash]
      # @return [Integer, Float]
      #
      # @api private
      # @sinc 0.1.0
      def increment(key, value, **options)
        raise NotImplementedError
      end

      # @param key [String]
      # @param value [Integer, Float]
      # @param options [Hash]
      # @return [Integer, Float]
      #
      # @api private
      # @since 0.1.0
      def decrement(key, value, **options)
        raise NotImplementedError
      end

      # @param key [String]
      # @option expires_in [Integer]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def re_expire(key, expires_in:)
        raise NotImplementedError
      end

      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def clear(**options)
        raise NotImplementedError
      end
    end
  end
end
