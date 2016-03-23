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
          return if hash.is_a? String
          h = {
            :timestamp => Time.now.to_s,
            :id        => user_id,
            :level     => level.to_s
          }.merge hash
          hash = flatten_values_to_s h unless @nesting
          @log_file.write(::JSON.generate(hash) + "\n")
        end
      end

      private

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end

      def user_id
        id = session[:user_id] if respond_to?(:session)
        id.nil? ? "n/a" : id
      end
    end
  end
end
