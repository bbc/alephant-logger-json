require 'spec_helper'
require 'alephant/logger/level_checker'
require_relative 'support/level_checker_shared_examples'

RSpec.describe Alephant::Logger::LevelChecker do
  describe '.logs?' do
    subject do
      described_class.logs?(
        message_level: message_level,
        desired_level: desired_level
      )
    end

    context 'Message level' do
      let(:message_level) { :info }

      context 'when message level is higher than desired level' do
        context 'Symbol' do
          let(:desired_level) { :debug }

          it_behaves_like 'a loggable level'
        end

        context 'String' do
          let(:desired_level) { 'debug' }

          it_behaves_like 'a loggable level'
        end

        context 'Integer' do
          let(:desired_level) { 0 }

          it_behaves_like 'a loggable level'

          context 'when out of range' do
            let(:desired_level) { -200 }

            it_behaves_like 'a loggable level'
          end
        end
      end

      context 'when message level is lower than desired level' do
        context 'Symbol' do
          let(:desired_level) { :warn }

          it_behaves_like 'a non loggable level'
        end

        context 'String' do
          let(:desired_level) { 'warn' }

          it_behaves_like 'a non loggable level'
        end

        context 'Integer' do
          let(:desired_level) { 3 }

          it_behaves_like 'a non loggable level'

          context 'when out of range' do
            let(:desired_level) { 100 }

            it_behaves_like 'a non loggable level'
          end
        end
      end

      context 'when message level is equal to desired level' do
        context 'Symbol' do
          let(:desired_level) { message_level }

          it_behaves_like 'a loggable level'
        end

        context 'String' do
          let(:desired_level) { message_level.to_s }

          it_behaves_like 'a loggable level'
        end

        context 'Integer' do
          let(:desired_level) { 1 }

          it_behaves_like 'a loggable level'
        end
      end

      context 'when unsupported type' do
        context 'Hash' do
          let(:message_level) { :error }
          let(:desired_level) { {} }

          it 'raises an argument error' do
            expect { subject }.to raise_error(
              ArgumentError,
              /wrong type of argument: should be an Integer, Symbol or String./
            )
          end
        end
      end
    end
  end
end
