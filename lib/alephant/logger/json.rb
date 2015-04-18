require "json"

module Alephant
  module Logger
    class JSON
      def initialize(log_path)
        @log_file = File.open(log_path, "a+")
        @log_file.sync = true
      end

      [:debug, :info, :warn, :error].each do |level|
        define_method(level) do |hash|
          hash["level"] = level.to_s
          @log_file.write(::JSON.generate(hash) + "\n")
        end
      end
    end
  end
end

