require 'date'
require 'spec_helper'
require 'alephant/logger/json_to_io'
require_relative 'support/json_shared_examples'

describe Alephant::Logger::JSONtoIO do
  let(:fn) { -> { 'foo' } }
  let(:log_output_obj) { spy }
  let(:msg) { :puts }

  subject { described_class.new(log_output_obj) }

  %w(debug info warn error).each do |level|
    describe "##{level}" do
      let(:level) { level }

      it_behaves_like 'a JSON log writer'

      it_behaves_like 'nests flattened to strings'

      it_behaves_like 'gracefully fails with string arg'

      context 'with nesting allowed' do
        subject { described_class.new(log_output_obj, nesting: true) }

        it_behaves_like 'nesting allowed'
      end
    end
  end
end
