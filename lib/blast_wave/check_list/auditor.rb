# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::Auditor
    require_relative 'auditor/result'

    # @param checker [BlastWave::CheckList::Checker]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(checker)
      @checker = checker
    end

    # @param env [Hash]
    # @option lockable [Boolean]
    # @option check_all [Boolean]
    # @return [Result]
    #
    # @api private
    # @since 0.1.0
    def audit!(env, lockable: false, check_all: false)
      Result.new
    end

    private

    # @return [BlastWave::CheckList::Checker]
    #
    # @api private
    # @since 0.1.0
    attr_reader :checker

    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def no_filters?
      checker.empty?
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def match?(env, audit_result, check_all: false)
      checker.check!(Rack::Request.new(env), check_all: check_all) do |triggered_filter|
        audit_result.triggered_filters << triggered_filter.name
      end
    end
  end
end
