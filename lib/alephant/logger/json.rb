require "json"
require "binding_of_caller"

module Alephant
  module Logger
    class JSON
      def initialize(log_path, options = {})
        @log_file = File.open(log_path, "a+")
        @log_file.sync = true
        @nesting = options.fetch(:nesting, false)
        @log_methods = options.fetch(:log_methods, false)
      end

      [:debug, :info, :warn, :error].each do |level|
        define_method(level) do |hash|
          return if hash.is_a? String

          hash["method"] = calling_method if @log_methods

          hash["level"] = level.to_s
          hash = flatten_values_to_s hash unless @nesting
          @log_file.write(::JSON.generate(hash) + "\n")
        end
      end

      private

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end

      def calling_method
        binding
          .of_caller(2)
          .eval '"#{self.class.name}##{__method__}"'
      end
    end
  end
end
