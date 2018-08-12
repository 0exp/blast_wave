# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  module BlastWave::CheckList::Builder
    # @return [Proc]
    #
    # @api private
    # @since 0.1.0
    # rubocop:disable Metrics/BlockLength
    INSTRUCTIONS = proc do
      # @since 0.1.0
      include Qonfig::Configurable
      # @since 0.1.0
      include BlastWave::CheckList::Checkable

      # @since 0.1.0
      configuration do
        setting :check_all, false

        setting :fail_response do
          setting :body,    BlastWave::CheckList::FailResponse::DEFAULT_BODY
          setting :status,  BlastWave::CheckList::FailResponse::DEFAULT_STATUS
          setting :headers, BlastWave::CheckList::FailResponse::DEFAULT_HEADERS
        end
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
    # rubocop:enable Metrics/BlockLength

    class << self
      # @param empty_middleware_klass [Class<BlastWave::MiddleWare>]
      # @return [Class<BlastWave::MiddleWare>]
      #
      # @api public
      # @since 0.1.0
      def build(empty_middleware_klass = Class.new(BlastWave::Middleware))
        empty_middleware_klass.class_eval(&INSTRUCTIONS)
      end
    end
  end
end
