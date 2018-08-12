# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::MatcherRegistry
    # @since 0.1.0
    include Enumerable

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize
      @list = []
      @lock = Mutex.new
    end

    # @param matcher [BlastWave::CheckList::Matcher]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(matcher)
      lock.synchronize { list << matcher }
    end

    # @param block [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def each(&block)
      block_given? ? list.each(&block) : list.each
    end

    private

    # @return [Array]
    #
    # @api private
    # @since 0.1.0
    attr_reader :list

    # @return [Mutex]
    #
    # @api private
    # @since 0.1.0
    attr_reader :lock
  end
end
