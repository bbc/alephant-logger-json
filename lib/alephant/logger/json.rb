require_relative "./dynamic_binding.rb"
require "json"

module Alephant
  module Logger
    class JSON
      def initialize(log_path, options = {})
        @log_file      = File.open(log_path, "a+")
        @log_file.sync = true
        @nesting       = options.fetch(:nesting, false)
        @@session      = -> { "n/a" } unless defined? @@session
      end

      [:debug, :info, :warn, :error].each do |level|
        define_method(level) do |b = nil, hash|
          return if hash.is_a? String

          h = {
            timestamp: Time.now.to_s,
            uuid:      b.nil? ? 'n/a' : @@session.call_with_binding(b),
            level:     level.to_s
          }.merge(hash)

          hash = flatten_values_to_s(h) unless @nesting

          write(hash)
        end
      end

      def self.session(fn)
        @@session = fn
      end

      def self.session?
        defined?(@@session)
      end

      private

      def write(hash)
        @log_file.write(::JSON.generate(hash) + "\n")
      end

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end
    end
  end
end
