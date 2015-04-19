require "json"

module Alephant
  module Logger
    class JSON
      def initialize(log_path, allow_nesting = false)
        @log_file = File.open(log_path, "a+")
        @log_file.sync = true
        @allow_nesting = allow_nesting
      end

      private

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end

      public

      [:debug, :info, :warn, :error].each do |level|
        define_method(level) do |hash|
          hash["level"] = level.to_s

          hash = flatten_values_to_s hash if not @allow_nesting

          @log_file.write(::JSON.generate(hash) + "\n")
        end
      end
    end
  end
end

