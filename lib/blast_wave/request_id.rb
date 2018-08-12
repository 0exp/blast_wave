# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::RequestId < BlastWave::Middleware
    require_relative 'request_id/extensions/request_interface'
    require_relative 'request_id/initializer'

    # @since 0.1.0
    include Qonfig::Configurable

    # @return [String]
    #
    # @api public
    # @since 0.1.0
    REQUEST_ID_ENV_KEY = 'rack.blastwave.request_id'

    # @since 0.1.0
    configuration { setting :id_randomizer, -> { SecureRandom.hex } }

    # @param app [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(app)
      super
      Initializer.call(app)
    end

    # @param env [Hash]
    # @return [Object]
    #
    # @see Rack::BlastWave::Middleware
    #
    # @api private
    # @since 0.1.0
    def call(env)
      append_request_id!(env)
      super
    end

    private

    # @return [String]
    #
    # @see generate_request_id
    #
    # @api private
    # @since 0.1.0
    def append_request_id!(env)
      env[REQUEST_ID_ENV_KEY] = generate_request_id
    end

    # @return [String]
    #
    # @api private
    # @since 0.1.0
    def generate_request_id
      self.class.config.settings.id_randomizer.call
    end
  end
end
