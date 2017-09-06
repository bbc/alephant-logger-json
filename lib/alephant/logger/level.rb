module Alephant
  module Logger
    LEVELS = %i(debug info warn error).freeze

    class Level
      def initialize(log_level)
        @log_level = log_level
      end

      def logs?(message_level)
        message_level_index(message_level) <= log_level_index
      end

      private

      attr_reader :log_level

      def message_level_index(message_level)
        case message_level
        when Symbol then level_index(message_level) || 0
        when Integer then message_level
        else
          raise ArgumentError,
                'wrong type of argument: should be an Integer or Symbol.'
        end
      end

      def log_level_index
        level_index(log_level)
      end

      def level_index(level)
        Alephant::Logger::LEVELS.index(level)
      end
    end
  end
end
