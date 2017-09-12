require 'date'
require 'spec_helper'
require 'alephant/logger/json_to_io'
require_relative 'support/json_shared_examples'

describe Alephant::Logger::JSONtoIO do
  let(:fn) { -> { 'foo' } }
  let(:log_output_obj) { spy }
  let(:msg) { :puts }

  logging_levels = Alephant::Logger::LEVELS.map(&:to_s)
  levels_size = logging_levels.size - 1

  %w(debug info warn error).each_with_index do |level, i|
    describe "##{level}" do
      let(:level) { level }
      let(:log_hash) { { 'foo' => 'bar', 'baz' => 'quux' } }

      context 'when message level is defined' do
        subject { described_class.new(log_output_obj, level: message_level) }

        context 'when same as message level' do
          let(:message_level) { level.to_sym }

          it_behaves_like 'a JSON log writer'

          it_behaves_like 'nests flattened to strings'

          it_behaves_like 'gracefully fails with string arg'
        end

        context 'when lower than the message level' do
          let(:message_level) do
            idx = logging_levels.index(level)
            logging_levels[i == levels_size ? i : idx + 1].to_sym
          end

          it_behaves_like 'a JSON log non writer' unless i == levels_size

          it_behaves_like 'gracefully fails with string arg'
        end

        context 'when higher than the message level' do
          let(:message_level) do
            logging_levels[i > 0 ? logging_levels.index(level) - 1 : 0].to_sym
          end

          it_behaves_like 'a JSON log writer'

          it_behaves_like 'nests flattened to strings'

          it_behaves_like 'gracefully fails with string arg'
        end

        context 'when invalid type' do
          context 'String' do
            let(:message_level) { level }

            it 'raises an argument error' do
              expect { subject.send(level, log_hash) }.to raise_error(
                ArgumentError,
                /wrong type of argument: should be an Integer or Symbol./
              )
            end
          end
        end
      end

      context 'when message level is not defined' do
        subject { described_class.new(log_output_obj) }

        it_behaves_like 'a JSON log writer'

        it_behaves_like 'nests flattened to strings'

        it_behaves_like 'gracefully fails with string arg'
      end

      context 'with nesting allowed' do
        subject { described_class.new(log_output_obj, nesting: true) }

        it_behaves_like 'nesting allowed'
      end
    end
  end
end
