# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class ActiveSupportFileStore < Delegator
      NO_EXPIRATION_TTL = nil

      DEFAULT_INCR_DECR_AMOUNT = 1

      def initialize(driver)
        super
        @lock = Mutex.new
      end

      def increment(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
        new_amount = nil

        synchronize do
          new_amount =
            if expires_in
              driver.increment(key, amount, expires_in: expires_in)
            else
              entry = get_entry(key)

              if entry
                entry_expiration = entry.expires_at
                new_expiration   = entry_expiration ? (entry_expiration - calc_epoch_time) : NO_EXPIRATION_TTL
                driver.increment(key, amount, expires_in: new_expiration)
              end
            end

          if new_amount.nil?
            new_amount = amount

            if expires_in
              write(key, amount, expires_in: expires_in)
            else
              write(key, amount)
            end
          end
        end

        new_amount
      end

      def decrement(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
        expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
        new_amount = nil

        synchronize do
          new_amount =
            if expires_in
              driver.decrement(key, amount, expires_in: expires_in)
            else
              entry = get_entry(key)

              if entry
                entry_expiration = entry.expires_at
                new_expiration   = entry_expiration ? (entry_expiration - calc_epoch_time) : NO_EXPIRATION_TTL
                driver.decrement(key, amount, expires_in: new_expiration)
              end
            end

          if new_amount.nil?
            new_amount = amount

            if expires_in
              write(key, 0 - amount, expires_in: expires_in)
            else
              write(key, 0 - amount)
            end
          end
        end

        new_amount
      end

      def re_expire(key, expires_in:)
        get_entry(key).tap do |entry|
          write(key, entry.value, expires_in: expires_in) if entry
        end
      end

      private

      attr_reader :lock

      def calc_epoch_time
        Time.now.to_f
      end

      def synchronize(&block)
        lock.synchronize { block.call }
      end

      def get_entry(key)
        driver.instance_eval do
          options = merged_options(nil)
          searched_entry = nil

          search_dir(cache_path) do |fname|
            entry = read_entry(fname, options)
            name = file_path_key(fname)

            searched_entry = entry if name == key
          end

          searched_entry
        end
      end
    end
  end
end
