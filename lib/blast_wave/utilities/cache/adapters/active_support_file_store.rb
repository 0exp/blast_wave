# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class ActiveSupportFileStore < Delegator
      require_relative 'active_support_file_store/operation'
      require_relative 'active_support_file_store/increment'
      require_relative 'active_support_file_store/decrement'
      require_relative 'active_support_file_store/re_expire'

      class << self
        # @param driver [Object]
        # @return [Boolean]
        #
        # @api private
        # @since 0.1.0
        def supported_driver?(driver)
          defined?(::ActiveSupport::Cache::FileStore) &&
            driver.is_a?(::ActiveSupport::Cache::FileStore)
        end
      end

      # @param driver [Object]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def initialize(driver)
        super
        @lock = Concurrent::ReentrantReadWriteLock.new
        @incr_operation = Increment.new(driver)
        @decr_operation = Decrement.new(driver)
        @rexp_operation = ReExpire.new(driver)
      end

      # @param key [String]
      # @param options [Hash]
      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      def read(key, **options)
        lock.with_read_lock { super }
      end

      # @param key [String]
      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def delete(key, **options)
        lock.with_write_lock { super }
      end

      # @param key [String]
      # @param value [Object]
      # @param options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def write(key, value, **options)
        lock.with_write_lock { super }
      end

      # @param key [String]
      # @param
      def increment(key, amount = Increment::DEFAULT_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, Operation::NO_EXPIRATION_TTL)

        lock.with_write_lock { incr_operation.call(key, amount, expires_in: expires_in) }
      end

      # @param key [String]
      # @param
      def decrement(key, amount = Decrement::DEFAULT_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, Operation::NO_EXPIRATION_TTL)

        lock.with_write_lock { decr_operation.call(key, amount, expires_in: expires_in) }
      end

      # @param key [String]
      # @param
      def re_expire(key, expires_in: Operation::NO_EXPIRATION_TTL)
        lock.with_write_lock { rexp_operation.call(key, expires_in: expires_in) }
      end

      private

      # @return [Concurrent::ReentrantReadWriteLock]
      #
      # @api private
      # @since 0.1.0
      attr_reader :lock

      # @return [Operation::Increment]
      #
      # @api private
      # @since 0.1.0
      attr_reader :incr_operation

      # @return [Operation::Decrement]
      #
      # @api private
      # @since 0.1.0
      attr_reader :decr_operation

      # @return [Operation::ReExpire]
      #
      # @api private
      # @since 0.1.0
      attr_reader :rexp_operation
    end
  end
end
