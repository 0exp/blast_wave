# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::WhiteList < BlastWave::CheckList
    BlastWave::CheckList::Builder.build(self)

    # @param env [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def call(env)
      check!(env) ? super : generate_fail_response!
    end
  end
end
