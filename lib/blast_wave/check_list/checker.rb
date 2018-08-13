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
      @filter_registry = BlastWave::CheckList::FilterRegistry.new
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
      filter_registry.clear!
    end

    # @param block [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(name = nil, &block)
      filter_registry.register(BlastWave::CheckList::Filter.new(name, block))
    end

    private

    # @return [BlastWave::CheckList::FilterRegistry]
    #
    # @api private
    # @since 0.1.0
    attr_reader :filter_registry

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def any?(request)
      filter_registry.any? { |filter| filter.match?(request) }
    end

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def all?(request)
      filter_registry.all? { |filter| filter.match?(request) }
    end
  end
end
