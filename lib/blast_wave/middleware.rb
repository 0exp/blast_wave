# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::Middleware
    # @return [Object]
    #
    # @api public
    # @since 0.1.0
    attr_reader :app

    # @param app [Object]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def initialize(app)
      @app = app
    end

    # @param env [Hash]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def call(env)
      app.call(env)
    end
  end
end
