module Alephant
  module Logger
    LEVELS = %i(debug info warn error).freeze

    class Level
      def initialize(message_level)
        @message_level = message_level
      end

      def logs?(desired_write_level)
        message_level_index >= desired_write_level_index(desired_write_level)
      end

      private

      attr_reader :message_level

      def desired_write_level_index(desired_write_level)
        case desired_write_level
        when Symbol then level_index(desired_write_level) || 0
        when Integer then desired_write_level
        else
          raise ArgumentError,
                'wrong type of argument: should be an Integer or Symbol.'
        end
      end

      def message_level_index
        level_index(message_level)
      end

      def level_index(level)
        Alephant::Logger::LEVELS.index(level)
      end
    end
  end
end
