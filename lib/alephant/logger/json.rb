require "json"

module Alephant
  module Logger
    class JSON
      def initialize(log_path, options = {})
        @log_file = File.open(log_path, "a+")
        @log_file.sync = true
        @nesting = options.fetch(:nesting, false)
      end

      [:debug, :info, :warn, :error].each do |level|
        define_method(level) do |hash|
          begin
            hash["level"] = level.to_s
            hash = flatten_values_to_s hash unless @nesting
            @log_file.write(::JSON.generate(hash) + "\n")
          rescue IndexError
          end
        end
      end

      private

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end
    end
  end
end
