# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::WhiteList < BlastWave::CheckList
    require_relative 'white_list/extensions/request_interface'
    require_relative 'white_list/initializer'
    require_relative 'white_list/auditor'

    # @return [String]
    #
    # @api private
    # @since 0.1.0
    ENVIRONMENT_KEY = 'rack.blastwave.white_list'

    # @param [Object] app
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(app)
      super
      Initializer.call(app)
    end
  end
end
