# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::FilterRegistry
    # @since 0.1.0
    include Enumerable

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize
      @filters = Concurrent::Array.new
    end

    # @param matcher [BlastWave::CheckList::Filter]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(filter)
      filters << filter
    end

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear!
      filters.clear
    end

    # @param block [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def each(&block)
      block_given? ? filters.each(&block) : filters.each
    end

    private

    # @return [Array]
    #
    # @api private
    # @since 0.1.0
    attr_reader :filters
  end
end
