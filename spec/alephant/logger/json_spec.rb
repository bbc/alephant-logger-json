require 'date'
require 'spec_helper'
require 'alephant/logger/json'
require 'alephant/logger/levels_controller'
require_relative 'support/json_shared_examples'

describe Alephant::Logger::JSON do
  let(:fn)       { -> { 'foo' } }
  let(:log_path) { '/log/path.log' }
  let(:log_output_obj) { instance_double(File) }
  let(:msg) { :write }

  before do
    allow(File).to receive(:open) { log_output_obj }
    allow(log_output_obj).to receive :sync=
  end

  logging_levels = Alephant::Logger::LevelsController::LEVELS

  logging_levels.each_with_index do |level, i|
    describe "##{level}" do
      let(:level) { level }
      let(:log_hash) { { 'foo' => 'bar', 'baz' => 'quux' } }

      context 'when write level is specified' do
        subject(:logger) do
          described_class.new(log_path, write_level: write_level)
        end

        context 'when message level is same as write level' do
          context 'Symbol' do
            let(:write_level) { level }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end

          context 'String' do
            let(:write_level) { level.to_s }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end

          context 'Integer' do
            let(:write_level) { logging_levels.index(level) }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end
        end

        context 'when message level is lower than write level' do
          context 'Integer' do
            let(:write_level) { logging_levels.index(level) + 1 }

            it_behaves_like 'a JSON log non writer'

            it_behaves_like 'gracefully fails with string message'
          end
        end

        context 'when message level is higher than write level' do
          let(:write_level_index) do
            i > 0 ? logging_levels.index(level) - 1 : 0
          end

          context 'Symbol' do
            let(:write_level) { logging_levels[write_level_index] }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end

          context 'String' do
            let(:write_level) { logging_levels[write_level_index].to_s }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end

          context 'Symbol' do
            let(:write_level) { write_level_index }

            it_behaves_like 'a JSON log writer'

            it_behaves_like 'nested JSON message flattened to strings'

            it_behaves_like 'gracefully fails with string message'
          end
        end
      end

      context 'when write level is not specified' do
        subject(:logger) { described_class.new(log_path) }

        it_behaves_like 'a JSON log writer'

        it_behaves_like 'nested JSON message flattened to strings'

        it_behaves_like 'gracefully fails with string message'
      end

      context 'with nesting allowed' do
        subject(:logger) { described_class.new(log_path, nesting: true) }

        it_behaves_like 'nesting allowed'
      end
    end
  end
end
