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
      @filters = Concurrent::Map.new
    end

    # @param matcher [BlastWave::CheckList::Filter]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(filter)
      filters[filter.name] = filter
    end

    # @param name [Object]
    # @return [Blastwave::CheckList::Filter]
    #
    # @api private
    # @since 0.1.0
    def fetch(name)
      filters[name]
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
      block_given? ? filters.values.each(&block) : filters.values.each
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def empty?
      filters.empty?
    end

    private

    # @return [Array]
    #
    # @api private
    # @since 0.1.0
    attr_reader :filters
  end
end
