# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::Checker
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize
      @matcher_registry = BlastWave::CheckList::MatcherRegistry.new
    end

    # @param request [Rack::Request]
    # @option check_all [Boolean]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def check!(request, check_all: false)
      check_all ? all?(request) : any?(request)
    end

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear!
      matcher_registry.clear!
    end

    # @param block [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(&block)
      matcher_registry.register(BlastWave::CheckList::Matcher.new(block))
    end

    private

    # @return [BlastWave::CheckList::MatcherRegistry]
    #
    # @api private
    # @since 0.1.0
    attr_reader :matcher_registry

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def any?(request)
      matcher_registry.any? { |matcher| matcher.match?(request) }
    end

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def all?(request)
      matcher_registry.all? { |matcher| matcher.match?(request) }
    end
  end
end
