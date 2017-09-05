require 'date'
require 'spec_helper'
require 'alephant/logger/json'
require 'alephant/logger/level'
require_relative 'shared_examples'

describe Alephant::Logger::JSON do
  let(:fn)       { -> { 'foo' } }
  let(:log_path) { '/log/path.log' }
  let(:log_output_obj) { instance_double File }

  before do
    allow(File).to receive(:open) { log_output_obj }
    allow(log_output_obj).to receive :sync=
  end

  logging_levels = Alephant::Logger::LEVELS.map(&:to_s)

  %w(debug info warn error).each_with_index do |level, i|
    describe "##{level}" do
      let(:level) { level }
      let(:log_hash) { { 'foo' => 'bar', 'baz' => 'quux' } }

      levels_size = logging_levels.size - 1

      context 'when desired log level is defined' do
        subject { described_class.new(log_path, level: desired_level) }

        context 'when same as defined' do
          let(:desired_level) { level.to_sym }

          it_behaves_like 'a JSON log writer', :write

          it_behaves_like 'nests flattened to strings', :write

          it_behaves_like 'gracefully fails with string arg', :write
        end

        context 'when greater than defined' do
          let(:desired_level) do
            idx = logging_levels.index(level)
            logging_levels[i == levels_size ? i : idx + 1].to_sym
          end

          if i < levels_size
            it_behaves_like 'a JSON log non writer', :write
          else
            it_behaves_like 'a JSON log writer', :write

            it_behaves_like 'nests flattened to strings', :write
          end

          it_behaves_like 'gracefully fails with string arg', :write
        end

        context 'when less than defined' do
          let(:desired_level) do
            logging_levels[i > 0 ? logging_levels.index(level) - 1 : 0].to_sym
          end

          it_behaves_like 'a JSON log writer', :write

          it_behaves_like 'nests flattened to strings', :write

          it_behaves_like 'gracefully fails with string arg', :write
        end

        context 'when invalid type' do
          context 'String' do
            let(:desired_level) { level }

            it 'raises an argument error' do
              expect { subject.send(level, log_hash) }.to raise_error(
                ArgumentError,
                /wrong type of argument: should be an Integer or Symbol./
              )
            end
          end
        end
      end

      context 'when desired log level is not defined' do
        subject { described_class.new(log_path) }

        it_behaves_like 'a JSON log writer', :write

        it_behaves_like 'nests flattened to strings', :write

        it_behaves_like 'gracefully fails with string arg', :write
      end

      context 'with nesting allowed' do
        subject do
          described_class.new(log_path, nesting: true)
        end

        it_behaves_like 'nesting allowed', :write
      end
    end
  end
end
