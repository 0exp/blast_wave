# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::BlackList::Auditor < BlastWave::CheckList::Auditor
    # @param env [Hash]
    # @option lockable [Boolean]
    # @option check_all [Boolean]
    # @return [Auditor::Result]
    #
    # @api private
    # @since 0.1.0
    def audit!(env, lockable: false, check_all: false)
      super.tap do |audit_result|
        next if no_filters?

        if match?(env, audit_result, check_all: check_all)
          audit_result.locked = true if lockable
        end
      end
    end
  end
end
