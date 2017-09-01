module Alephant
  module Logger

    LEVELS = %i(debug info warn error).freeze

    class Level
      def initialize(desired_level, defined_level)
        @desired_level = desired_level
        @defined_level = defined_level
      end

      def log?
        desired_level_pos >= defined_level_pos
      end

      private

      attr_reader :desired_level, :defined_level

      def desired_level_pos
        log_level(desired_level) || 0
      end

      def defined_level_pos
        log_level(defined_level)
      end

      def log_level(level)
        Alephant::Logger::LEVELS.index(level)
      end
    end
  end
end
