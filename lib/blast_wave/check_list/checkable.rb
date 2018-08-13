# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  module BlastWave::CheckList::Checkable
    class << self
      # @param base_klass [Class]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def included(base_klass)
        base_klass.extend(ClassMethods)
        base_klass.include(InstanceMethods)
        base_klass.instance_variable_set(:@checker, BlastWave::CheckList::Checker.new)
        base_klass.singleton_class.class_eval { attr_reader :checker }
      end
    end

    # @api private
    # @since 0.1.0
    module ClassMethods
      # @param block [Proc]
      # @return [void]
      #
      # @api public
      # @since 0.1.0
      def filter(name = nil, &block)
        checker.register(name, &block)
      end

      # @return [void]
      #
      # @api public
      # @since 0.1.0
      def clear!
        checker.clear!
      end
    end

    # @api private
    # @since 0.1.0
    module InstanceMethods
      # @return [BlastWave::CheckLis::Checker]
      #
      # @api private
      # @sicne 0.1.0
      def checker
        self.class.checker
      end
    end
  end
end
