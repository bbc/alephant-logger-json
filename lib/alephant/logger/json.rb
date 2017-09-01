require 'json'
require_relative 'dynamic_binding'
require_relative 'level'

module Alephant
  module Logger
    class JSON
      def initialize(log_path, options = {})
        @log_file          = File.open(log_path, 'a+')
        @log_file.sync     = true
        @nesting           = options.fetch(:nesting, false)
        @desired_level     = options.fetch(:level, :debug)
        self.class.session = -> { 'n/a' } unless self.class.session?
      end

      Alephant::Logger::LEVELS.each do |level|
        define_method(level) do |b = nil, hash|
          return if hash.is_a? String

          h = {
            timestamp: Time.now.to_s,
            uuid:      b.nil? ? 'n/a' : self.class.session.call_with_binding(b),
            level:     level.to_s
          }.merge(hash)

          hash = flatten_values_to_s(h) unless @nesting

          write(hash) if write_level?(level)
        end
      end

      class << self
        attr_accessor :session

        def session?
          defined?(@session)
        end
      end

      private

      def write(hash)
        @log_file.write(::JSON.generate(hash) + "\n")
      end

      def write_level?(level)
        Alephant::Logger::Level.new(@desired_level, level).log?
      end

      def flatten_values_to_s(hash)
        Hash[hash.map { |k, v| [k, v.to_s] }]
      end
    end
  end
end
