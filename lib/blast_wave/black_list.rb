# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::BlackList < BlastWave::CheckList
    # @param env [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def call(env)
      check!(env) ? generate_fail_response! : super
    end
  end
end
