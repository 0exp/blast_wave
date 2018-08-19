# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  module BlastWave::CheckList::Builder
    # @return [Proc]
    #
    # @api private
    # @since 0.1.0
    CLASS_DEFINITIONS = proc do |check_all: false|
      # @since 0.1.0
      include Qonfig::Configurable
      # @since 0.1.0
      include BlastWave::CheckList::Checkable

      # @since 0.1.0
      configuration do
        setting :check_all, check_all
        setting :lock_requests, true

        setting :fail_response do
          setting :body,    BlastWave::CheckList::FailResponse::DEFAULT_BODY
          setting :status,  BlastWave::CheckList::FailResponse::DEFAULT_STATUS
          setting :headers, BlastWave::CheckList::FailResponse::DEFAULT_HEADERS
        end
      end
    end

    class << self
      # @param empty_middleware_klass [Class<BlastWave::MiddleWare>]
      # @return [Class<BlastWave::MiddleWare>]
      #
      # @api public
      # @since 0.1.0
      def build(empty_middleware_klass = Class.new(BlastWave::Middleware), &additionals)
        empty_middleware_klass.tap do |middleware_klass|
          middleware_klass.class_eval(&CLASS_DEFINITIONS)
          middleware_klass.class_eval(&additionals) if block_given?
        end
      end
    end
  end
end
