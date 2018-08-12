# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::WhiteList < BlastWave::Middleware
    require_relative 'white_list/matcher'
    require_relative 'white_list/matcher_registry'
    require_relative 'white_list/checker'
    require_relative 'white_list/fail_response'
    require_relative 'white_list/checkable'

    # @since 0.1.0
    include Qonfig::Configurable
    # @since 0.1.0
    include Checkable

    # @since 0.1.0
    configuration do
      setting :check_all, false

      setting :fail_response do
        setting :body,    FailResponse::DEFAULT_BODY
        setting :status,  FailResponse::DEFAULT_STATUS
        setting :headers, FailResponse::DEFAULT_HEADERS
      end
    end

    # @param env [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def call(env)
      check!(env) ? super : generate_fail_response!
    end

    private

    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.1.0
    def options
      self.class.config.settings
    end

    # @param env [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def check!(env)
      request = Rack::Request.new(env)
      should_check_all = options.check_all?
      checker.check!(request, check_all: should_check_all)
    end

    # @return [Rack::Response]
    #
    # @api private
    # @since 0.1.0
    def generate_fail_response!
      FailResponse.build(
        status:  options.fail_response.status,
        body:    options.fail_response.body,
        headers: options.fail_response.headers
      )
    end
  end
end
