# frozen_string_literal: true

module Rack
  class BlastWave::Utilities::Cache::Adapters::ActiveSupportFileStore
    # @api private
    # @since 0.1.0
    class Operation
      # @since 0.1.0
      extend Forwardable

      # @return [NilClass]
      #
      # @api private
      # @since 0.1.0
      NO_EXPIRATION_TTL = nil

      # @since 0.1.0
      def_delegators :driver, :read, :write

      def initialize(driver)
        @driver = driver
      end

      private

      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      attr_reader :driver

      # @option as_integer [Boolean]
      # @return [Integer, Float]
      #
      # @api private
      # @since 0.1.0
      def calc_epoch_time(as_integer: false)
        as_integer ? Time.now.to_i : Time.now.to_f
      end

      # @param [ActiveSupport::Cache::Entry]
      # @return [NilClass, Integer]
      #
      # @api private
      # @since 0.1.0
      def calc_entry_expiration(entry)
        entry.expires_at ? (entry.expires_at - calc_epoch_time) : NO_EXPIRATION_TTL
      end

      # @param key [String]
      # @return [NilClass, ActiveSupport::Cache::Entry]
      #
      # @api private
      # @since 0.1.0
      def fetch_entry(key)
        driver.instance_eval do
          read_options   = merged_options(nil)
          searched_entry = nil

          search_dir(cache_path) do |fname|
            entry_object = read_entry(fname, read_options)
            entry_name   = file_path_key(fname)

            searched_entry = entry_object if entry_name == key
          end

          searched_entry
        end
      end
    end
  end
end
