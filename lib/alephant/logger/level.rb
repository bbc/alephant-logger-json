module Alephant
  module Logger
    LEVELS = %i(debug info warn error).freeze

    class Level
      def initialize(desired, defined)
        @desired = desired
        @defined = defined
      end

      def log?
        desired_level <= defined_level
      end

      private

      attr_reader :desired, :defined

      def desired_level
        log_level(desired) || 0
      end

      def defined_level
        log_level(defined)
      end

      def log_level(level)
        Alephant::Logger::LEVELS.index(level)
      end
    end
  end
end
