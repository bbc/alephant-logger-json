require 'spec_helper'
require 'alephant/logger/level'
require_relative 'support/level_shared_examples'

RSpec.describe Alephant::Logger::Level do
  subject { described_class.new(log_level) }

  describe '#logs?' do
    context 'Message level' do
      context 'when defined as a Symbol' do
        let(:log_level) { :info }

        context 'when less than the log level' do
          let(:message_level) { :debug }

          it_behaves_like 'a writeable log'
        end

        context 'when greater than the log level' do
          let(:message_level) { :warn }

          it_behaves_like 'a non writeable log'
        end

        context 'when same as the log level' do
          let(:message_level) { log_level }

          it_behaves_like 'a writeable log'
        end
      end

      context 'when defined as an Integer' do
        let(:log_level) { :warn }

        context 'when less than the log level' do
          let(:message_level) { 0 }

          it_behaves_like 'a writeable log'

          context 'when out of range' do
            let(:message_level) { -200 }

            it_behaves_like 'a writeable log'
          end
        end

        context 'when greater than the log level' do
          let(:message_level) { 3 }

          it_behaves_like 'a non writeable log'

          context 'when out of range' do
            let(:message_level) { 100 }

            it_behaves_like 'a non writeable log'
          end
        end
      end

      context 'Unsupported types' do
        context 'String' do
          let(:log_level) { :error }
          let(:message_level) { 'debug' }

          it 'raises an argument error' do
            expect { subject.logs?(message_level) }.to raise_error(
              ArgumentError,
              /wrong type of argument: should be an Integer or Symbol./
            )
          end
        end
      end
    end
  end
end
