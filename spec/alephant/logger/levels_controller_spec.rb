require 'spec_helper'
require 'alephant/logger/levels_controller'
require_relative 'support/levels_controller_shared_examples'

RSpec.describe Alephant::Logger::LevelsController do
  describe '.should_log?' do
    subject(:loggable?) do
      described_class.should_log?(
        message_level: message_level,
        desired_level: desired_level
      )
    end

    describe 'Message level' do
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

      context 'when message level is invalid' do
        let(:desired_level) { :debug }

        context 'when message level is not in LEVELS' do
          let(:message_level) { :foobar }

          it_behaves_like 'a non loggable level'
        end

        context 'when message level is nil' do
          let(:message_level) { nil }

          it_behaves_like 'a non loggable level'
        end
      end
    end

    describe 'Desired level' do
      context 'when desired level is not in LEVELS' do
        let(:message_level) { :error }
        let(:desired_level) { :foobar }

        it 'defaults to debug' do
          expect(loggable?).to be(true)
        end
      end

      context 'when desired level is an unsupported type' do
        context 'Hash' do
          let(:message_level) { :error }
          let(:desired_level) { {} }

          it 'raises an argument error' do
            expect { loggable? }.to raise_error(
              ArgumentError,
              'wrong type of argument: expected Integer, '\
              'Symbol or String. got Hash'
            )
          end
        end

        context 'Nil' do
          let(:message_level) { :error }
          let(:desired_level) { nil }

          it 'raises an argument error' do
            expect { loggable? }.to raise_error(
              ArgumentError,
              'wrong type of argument: expected Integer, '\
              'Symbol or String. got NilClass'
            )
          end
        end
      end
    end
  end
end
