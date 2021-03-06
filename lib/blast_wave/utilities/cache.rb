# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::Utilities::Cache
    require_relative 'cache/adapters'

    # @since 0.1.0
    extend Forwardable

    class << self
      # @param driver [Object]
      # @return [BlastWave::Utilities::Cache]
      #
      # @api private
      # @since 0.1.0
      def build(driver)
        new(Adapters.build(driver))
      end
    end

    # @since 0.1.0
    def_delegators :adapter, :read, :write, :delete, :increment, :decrement, :re_expire, :clear

    # @param adapter [BlastWave::Utilities::Cache::Adapters::Basic]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(adapter)
      @adapter = adapter
    end

    private

    # @return [BlastWave::Utilities::Cache::Adapters::Basic]
    #
    # @api private
    # @since 0.1.0
    attr_reader :adapter
  end
end
