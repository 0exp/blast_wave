# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::Filter
    # @return [Object] #call-able object
    #
    # @api private
    # @since 0.1.0
    attr_reader :matcher

    # @return [String]
    #
    # @api private
    # @since 0.1.0
    attr_reader :name

    # @param matcher [Object] #call-able object
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(name, matcher)
      @name    = name
      @matcher = matcher
    end

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def match?(request)
      !!matcher.call(request)
    end
    alias_method :call, :match?
  end
end
