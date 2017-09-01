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
    end
  end
end
