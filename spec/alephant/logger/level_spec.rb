require 'spec_helper'
require 'alephant/logger/level'

RSpec.describe Alephant::Logger::Level do
  subject { described_class.new(desired, defined) }

  describe '#log?' do
    context 'desired level' do
      context 'when less than defined level' do
        let(:desired) { :debug }
        let(:defined) { :info }

        it 'returns true' do
          expect(subject.log?).to be(true)
        end
      end

      context 'when greater than defined level' do
        let(:desired) { :warn }
        let(:defined) { :info }

        it 'returns false' do
          expect(subject.log?).to be(false)
        end
      end

      context 'when same as defined level' do
        let(:desired) { :info }
        let(:defined) { desired }

        it 'returns true' do
          expect(subject.log?).to be(true)
        end
      end

      context 'when invalid' do
        context 'Symbol' do
          let(:desired) { :foo }
          let(:defined) { :error }

          it 'defaults to true' do
            expect(subject.log?).to be(true)
          end
        end

        context 'Integer' do
          let(:defined) { :error }
          context 'greater than defined' do
            let(:desired) { 100 }

            it 'defaults to false' do
              expect(subject.log?).to be(false)
            end
          end

          context 'less than defined' do
            let(:desired) { -1 }

            it 'defaults to true' do
              expect(subject.log?).to be(true)
            end
          end
        end

        context 'Unsupported types' do
          context 'String' do
            let(:desired) { 'debug' }
            let(:defined) { :error }

            it 'raises an argument error' do
              expect { subject.log? }.to raise_error(
                ArgumentError,
                /wrong type of argument: should be an Integer or Symbol./
              )
            end
          end
        end
      end
    end
  end
end
