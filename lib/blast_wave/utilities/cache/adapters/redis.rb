# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class Redis < Basic
      # @since 0.1.0
      def_delegators :driver,
                     :get,
                     :set,
                     :setex,
                     :del,
                     :incrby,
                     :decrby,
                     :pipelined,
                     :expire

      # @param key [String]
      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      def read(key)
        get(key)
      end

      # @param key [String]
      # @param value [Object]
      # @option expires_in [NilClass, Integer] Time in seconds
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def write(key, value, **options)
        expires_in = options.fetch(:expires_in, nil)

        expires_in ? setex(key, expires_in, value) : set(key, value)
      end

      # @param key [String]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def delete(key)
        del(key)
      end

      # @param key [String]
      # @param amount [Integer]
      # @option expires_in [NilClass, Integer] Time in seconds
      # @return [NilClass, Integer]
      #
      # @api private
      # @since 0.1.0
      def increment(key, amount, **options)
        expires_in = options.fetch(:expires_in, nil)
        new_amount = nil

        pipelined do
          new_amount = incrby(key, amount)
          expire(key, expires_in) if expires_in
        end

        new_amount && new_amount.value
      end

      # @param key [String]
      # @param amount [Integer]
      # @options expires_in [NillClass, Integer] Time in seconds
      # @return [NillClass, Integer]
      #
      # @api private
      # @since 0.1.0
      def decrement(key, amount, **options)
        expires_in = options.fetch(:expires_in, nil)
        new_amount = nil

        pipelined do
          new_amount = decrby(key, amount)
          expire(key, expires_in) if expires_in
        end

        new_amount && new_amount.value
      end
    end
  end
end
