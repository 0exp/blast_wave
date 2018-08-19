# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList < BlastWave::Middleware
    require_relative 'check_list/filter'
    require_relative 'check_list/filter_registry'
    require_relative 'check_list/fail_response'
    require_relative 'check_list/common_filters/ip_addrs'
    require_relative 'check_list/checkable'
    require_relative 'check_list/checker'
    require_relative 'check_list/auditor'
    require_relative 'check_list/builder'

    class << self
      # Creates a clone of the current middleware with it's own initial settings.
      #
      # @return [Class<BlastWave::CheckList>]
      #
      # @api public
      # @since 0.1.0
      def build
        Class.new(self)
      end

      # @param child_klass [Class]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def inherited(child_klass)
        BlastWave::CheckList::Builder.build(child_klass)
      end
    end

    # @param app [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(app)
      super
      @auditor = self.class::Auditor.new(checker)
    end

    # @param env [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def call(env)
      result = audit_request(env)
      append_env_data!(env, result)
      result.locked ? generate_fail_response! : super
    end

    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.1.0
    def options
      self.class.config.settings
    end

    private

    # @return [BlastWave::CheckList::Auditor]
    #
    # @api private
    # @since 0.1.0
    attr_reader :auditor

    # @param env [Hash]
    # @return [BlastWave::CheckList::Auditor::Result]
    #
    # @api private
    # @since 0.1.0
    def audit_request(env)
      auditor.audit!(env, lockable: options.lock_requests?, check_all: options.check_all?)
    end

    # @param env [Hash]
    # @param audit_result [BlastWave::CheckList::Auditor::Result]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def append_env_data!(env, audit_result)
      env[self.class::ENVIRONMENT_KEY] = {
        locked:            audit_result.locked,
        triggered_filters: audit_result.triggered_filters
      }
    end

    # @return [Rack::Response]
    #
    # @api private
    # @since 0.1.0
    def generate_fail_response!
      BlastWave::CheckList::FailResponse.build(
        status:  options.fail_response.status,
        body:    options.fail_response.body,
        headers: options.fail_response.headers
      ).finish
    end
  end
end
