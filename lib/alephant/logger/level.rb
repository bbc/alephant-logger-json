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
        case desired
        when Symbol then log_level(desired) || 0
        when Integer then desired >= 0 ? desired : 0
        else
          raise ArgumentError,
                'wrong type of argument: should be an Integer or Symbol.'
        end
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
