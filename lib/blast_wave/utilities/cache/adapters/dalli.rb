# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class Dalli < Basic
      # @since 0.1.0
      def_delegators :driver,
                     :get,
                     :set,
                     :incr,
                     :decr,
                     :multi,
                     :touch

      # @return [Integer]
      #
      # @api private
      # @since 0.1.0
      NO_EXPIRATION_TTL = 0

      # @return [Integer]
      #
      # @api private
      # @since 0.1.0
      DEFAULT_INCRDECR_AMOUNT = 1

      # @param key [String]
      # @param options [Hash]
      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      def read(key, **options)
        get(key)
      end

      def write(key, value, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

        set(key, value, expires_in, raw: true)
      end

      # @param key [String]
      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def delete(key, **options)
        driver.delete(key)
      end

      # @param key [String]
      # @param amount [Integer]
      # @option expires_in [NilClass, Integer]
      # @return [NilClass, Integer]
      #
      # @api private
      # @since 0.1.0
      def increment(key, amount = DEFAULT_INCRDECR_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

        incr(key, amount, expires_in, amount)
      end

      # @param key [String]
      # @param amount [Integer]
      # @option expires_in [NilClass, Integer]
      # @return [NilClass, Integer]
      #
      # @api private
      # @since 0.1.0
      def decrement(key, amount = DEFAULT_INCRDECR_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

        decr(key, amount, expires_in, amount)
      end

      # @param key [String]
      # @param period [Integer]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def re_expire(key, period = NO_EXPIRATION_TTL)
        touch(key, period)
      end
    end
  end
end
