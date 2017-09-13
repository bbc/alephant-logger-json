require 'spec_helper'
require 'alephant/logger/level'
require_relative 'support/level_shared_examples'

RSpec.describe Alephant::Logger::Level do
  subject(:level_logger) { described_class.new(message_level) }

  describe '#logs?' do
    context 'Message level' do
      let(:message_level) { :info }

      context 'when higher than the desired write level' do
        context 'Symbol' do
          let(:desired_write_level) { :debug }

          it_behaves_like 'a writeable log'
        end

        context 'Integer' do
          let(:desired_write_level) { 0 }

          it_behaves_like 'a writeable log'

          context 'when out of range' do
            let(:desired_write_level) { -200 }

            it_behaves_like 'a writeable log'
          end
        end
      end

      context 'when lower than the desired write level' do
        context 'Symbol' do
          let(:desired_write_level) { :warn }

          it_behaves_like 'a non writeable log'
        end

        context 'Integer' do
          let(:desired_write_level) { 3 }

          it_behaves_like 'a non writeable log'

          context 'when out of range' do
            let(:desired_write_level) { 100 }

            it_behaves_like 'a non writeable log'
          end
        end
      end

      context 'when equal to the desired write level' do
        context 'Symbol' do
          let(:desired_write_level) { message_level }

          it_behaves_like 'a writeable log'
        end

        context 'Integer' do
          let(:desired_write_level) { 1 }

          it_behaves_like 'a writeable log'
        end
      end

      context 'Unsupported types' do
        context 'String' do
          let(:message_level) { :error }
          let(:desired_write_level) { 'debug' }

          it 'raises an argument error' do
            expect { level_logger.logs?(desired_write_level) }.to raise_error(
              ArgumentError,
              /wrong type of argument: should be an Integer or Symbol./
            )
          end
        end
      end
    end
  end
end
