# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class Delegator < Basic
      # @since 0.1.0
      def_delegators :driver,
                     :read,
                     :write,
                     :delete,
                     :increment,
                     :decrement,
                     :re_expire
    end
  end
end
